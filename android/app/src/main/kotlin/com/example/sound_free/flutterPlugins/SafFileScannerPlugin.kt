package com.example.sound_free.flutterPlugins

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.core.net.toUri

class SafFileScannerPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {
    private val mChannel = "com.example.saf_file_scanner"
    private val mRequestCodeOpenDirectory = 1
    private var pendingResult: MethodChannel.Result? = null

    fun registerWith(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor, mChannel).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestDirectoryAccess" -> {
                pendingResult = result
                val directoryPath = call.argument<String>("directoryPath")
                requestDirectoryAccess(directoryPath)
            }

            "scanFiles" -> {
                val directoryUri = call.argument<String>("directoryUri")
                directoryUri?.let { scanFiles(it, result) } ?: result.error(
                    "NULL_URI",
                    "目录URI为空",
                    null
                )
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (resultCode != Activity.RESULT_OK) return

        if (requestCode == mRequestCodeOpenDirectory) {
            data?.data?.let { treeUri ->
                val resultMap = HashMap<String, Any?>()
                resultMap["uri"] = treeUri.toString()
                resultMap["path"] = getPathFromUri(treeUri)
                activity.contentResolver.takePersistableUriPermission(
                    treeUri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION
                )
                activity.contentResolver.takePersistableUriPermission(
                    treeUri,
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                )
                pendingResult?.success(resultMap)
                pendingResult = null
            }
        } else if (pendingResult != null) {
            pendingResult?.error("CANCELLED", "用户取消了目录选择", null)
            pendingResult = null
        }
    }

    private fun requestDirectoryAccess(directoryPath: String? = null) {
        val resultMap = HashMap<String, Any?>()
        var ok = false;
        Log.d(
            this::class.simpleName,
            "requestDirectoryAccess: 请求访问目录为 ${directoryPath ?: "空目录，请求打开访问器"}"
        )
        if (directoryPath != null) {
            try {
                resultMap["uri"] = ""
                resultMap["path"] = ""
                Log.d(
                    this::class.simpleName,
                    "requestDirectoryAccess: 开始对 $directoryPath 路径进行权限检查"
                )
                if (directoryPath.startsWith("/")) {
                    // 检查是否已经有该路径对应的任何持久化权限
                    val permissions = activity.contentResolver.persistedUriPermissions
                    // 尝试找到包含该路径的权限
                    for (permission in permissions) {
                        val documentFile =
                            DocumentFile.fromTreeUri(activity.applicationContext, permission.uri)
                        if (documentFile != null && documentFile.canRead() && documentFile.canWrite()) {
                            // 尝试将持久化URI转换为实际路径进行比较
                            val path = getPathFromUri(permission.uri)
                            // 检查请求的路径是否在已授权目录内或者是已授权目录本身
                            if (path != null && path == directoryPath) {
                                ok = true
                                resultMap["uri"] = permission.uri.toString()
                                resultMap["path"] = path
                                Log.d(
                                    this::class.simpleName,
                                    "requestDirectoryAccess: 路径 $directoryPath 经过检查已有读写权限"
                                )
                                break
                            }
                        }
                    }

                } else if (directoryPath.startsWith("content://")) {
                    val uri = directoryPath.toUri()
                    // 检查是否已经有该URI的持久化权限
                    val hasPermission = activity.contentResolver.persistedUriPermissions.any {
                        it.uri.toString() == uri.toString() &&
                                (it.isReadPermission && it.isWritePermission)
                    }
                    if (hasPermission) {
                        ok = true
                        resultMap["uri"] = uri.toString()
                        resultMap["path"] = getPathFromUri(uri)
                        Log.d(
                            this::class.simpleName,
                            "requestDirectoryAccess: 路径 $directoryPath 经过检查已有读写权限"
                        )
                    }
                }
                if (!ok) {
                    Log.d(
                        this::class.simpleName,
                        "requestDirectoryAccess: $directoryPath 路径经检查尚未获得权限"
                    )
                }
                pendingResult?.success(resultMap)
                pendingResult = null
            } catch (e: Exception) {
                // 错误处理，继续使用选择器
            }
        } else {
            // 如果没有提供有效路径或没有权限，弹出选择器
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
            activity.startActivityForResult(intent, mRequestCodeOpenDirectory)
        }
    }

    private fun getPathFromUri(uri: Uri): String? {
        try {
            val uriString = uri.toString()
            // 同时处理编码和非编码的情况
            if (uriString.startsWith("content://com.android.externalstorage.documents/tree/primary:") ||
                uriString.startsWith("content://com.android.externalstorage.documents/tree/primary%3A")
            ) {

                // 统一处理路径部分
                val path = uriString
                    .replace("content://com.android.externalstorage.documents/tree/primary:", "")
                    .replace("content://com.android.externalstorage.documents/tree/primary%3A", "")
                    .replace("%3A", ":")
                    .replace("%2F", "/")

                if (path.isEmpty()) {
                    return "/storage/emulated/0"
                }
                return "/storage/emulated/0/$path"
            }

            // 可以添加其他存储位置的处理逻辑

            return null
        } catch (e: Exception) {
            return null
        }
    }

    private fun scanFiles(directoryUriString: String, result: MethodChannel.Result) {
        try {
            val filesList = ArrayList<Map<String, Any?>>()
            val directoryUri = directoryUriString.toUri()
            val directory = DocumentFile.fromTreeUri(activity, directoryUri)
            Log.d(this::class.simpleName, "scanFiles: 将参数目录 $directoryUriString 转为Uri")
            if (directory == null || !directory.exists() || !directory.isDirectory) {
                Log.d(this::class.simpleName, "scanFiles: 参数目录 $directoryUriString 不是一个有效的路径或URI")
                result.success(filesList)
                return
            }
            for (file in directory.listFiles()) {
                val fileInfo = HashMap<String, Any?>()
                fileInfo["name"] = file.name
                fileInfo["uri"] = file.uri.toString()
                fileInfo["isDirectory"] = file.isDirectory
                fileInfo["isFile"] = file.isFile
                fileInfo["size"] = file.length()
                fileInfo["lastModified"] = file.lastModified()
                fileInfo["type"] = file.type
                filesList.add(fileInfo)
            }
            result.success(filesList)
        } catch (e: Exception) {
            Log.d(this::class.simpleName, "scanFiles: 扫描路径 $directoryUriString 时出错，错误信息为${e.message}")
            result.success(ArrayList<Map<String, Any?>>())
        }
    }
}
