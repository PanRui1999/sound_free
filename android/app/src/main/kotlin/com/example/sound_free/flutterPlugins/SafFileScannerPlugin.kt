package com.example.sound_free.flutterPlugins

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import android.util.Log
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.core.net.toUri

class SafFileScannerPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {
    private val mChannel = "com.sound_free.saf_file_directory_access"
    private val mRequestCodeOpenDirectory = 1
    private val mFileSelectorRequestCode = 2
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
                val extensions = call.argument<List<String>>("extensions")
                if (directoryUri != null && extensions != null) {
                    scanFiles(directoryUri, extensions, result)
                } else {
                    result.success(null)
                }
            }

            "selectFile" -> {
                pendingResult = result
                selectFile()
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (resultCode != Activity.RESULT_OK) return
        when (requestCode) {
            mRequestCodeOpenDirectory -> {
                data?.data?.let { treeUri ->
                    activity.contentResolver.takePersistableUriPermission(
                        treeUri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                    activity.contentResolver.takePersistableUriPermission(
                        treeUri,
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    )
                    pendingResult?.success(buildMap {
                        put("uri", treeUri.toString())
                        put("path", getPathFromUri(treeUri))
                    })
                }
                pendingResult = null
            }

            mFileSelectorRequestCode -> {
                data?.data?.let { treeUri ->
                    pendingResult?.success(buildMap {
                        put("uri", treeUri.toString())
                        put("path", getPathFromUri(treeUri))
                    })
                }
                pendingResult = null
            }
        }
    }

    private fun selectFile() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            // 设置文件类型为所有文件
            type = "*/*"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addCategory(Intent.CATEGORY_OPENABLE)
        }
        activity.startActivityForResult(intent, mFileSelectorRequestCode)
    }

    private fun requestDirectoryAccess(directoryPath: String? = null) {
        val resultMap = HashMap<String, Any?>()
        var ok = false
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
            Log.d(this::class.simpleName, "getPathFromUri: 开始对 $uriString 进行路径转换")
            // 同时处理编码和非编码的情况
            if (uriString.startsWith("content://com.android.externalstorage.documents/tree/primary:") ||
                uriString.startsWith("content://com.android.externalstorage.documents/tree/primary%3A")
            ) {
                val path = uriString
                    .replace("content://com.android.externalstorage.documents/tree/primary:", "")
                    .replace("content://com.android.externalstorage.documents/tree/primary%3A", "")
                    .replace("%3A", ":")
                    .replace("%2F", "/")

                if (path.isEmpty()) {
                    return "/storage/emulated/0"
                }
                Log.d(this::class.simpleName, "getPathFromUri: $uriString 进行路径转换为 ${"/storage/emulated/0/$path"}")
                return "/storage/emulated/0/$path"
            }

            // 对于文件类
            if (uriString.startsWith("content://com.android.externalstorage.documents/document/primary:") ||
                uriString.startsWith("content://com.android.externalstorage.documents/document/primary%3A")
            ) {
                val path = uriString
                    .replace("content://com.android.externalstorage.documents/document/primary:", "")
                    .replace("content://com.android.externalstorage.documents/document/primary%3A", "")
                    .replace("%3A", ":")
                    .replace("%2F", "/")

                if (path.isEmpty()) {
                    return "/storage/emulated/0"
                }
                Log.d(this::class.simpleName, "getPathFromUri: $uriString 进行路径转换为 ${"/storage/emulated/0/$path"}")
                return "/storage/emulated/0/$path"
            }

            return null
        } catch (e: Exception) {
            return null
        }
    }

    private fun scanFiles(
        directoryUriString: String,
        extensions: List<String>,
        result: MethodChannel.Result
    ) {
        try {
            val filesList = ArrayList<Map<String, Any?>>()
            val directoryUri = directoryUriString.toUri()
            val directory = DocumentFile.fromTreeUri(activity, directoryUri)
            Log.d(this::class.simpleName, "scanFiles: 将参数目录 $directoryUriString 转为Uri")
            if (directory == null || !directory.exists() || !directory.isDirectory) {
                Log.d(
                    this::class.simpleName,
                    "scanFiles: 参数目录 $directoryUriString 不是一个有效的路径或URI"
                )
                result.success(filesList)
                return
            }
            for (file in directory.listFiles()) {
                val extension = file.name?.substringAfterLast('.', "")?.lowercase()
                if (file.isDirectory) continue
                if (!extensions.any { ext ->
                        extension == ext.removePrefix(".").lowercase()
                    }) continue
                filesList.add(buildMap {
                    put("name", file.name?.substringBeforeLast("."))
                    put("uri", file.uri.toString())
                    put("path", getPathFromUri(file.uri))
                    put("suffix", extension)
                })
            }
            result.success(filesList)
        } catch (e: Exception) {
            Log.d(
                this::class.simpleName,
                "scanFiles: 扫描路径 $directoryUriString 时出错，错误信息为${e.message}"
            )
            result.success(ArrayList<Map<String, Any?>>())
        }
    }
}
