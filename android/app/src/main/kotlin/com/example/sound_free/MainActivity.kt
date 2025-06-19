package com.example.sound_free

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.saf_file_scanner"
    private val REQUEST_CODE_OPEN_DIRECTORY = 1
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
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
    }

    private fun requestDirectoryAccess(directoryPath: String? = null) {
        val resultMap = HashMap<String, Any?>()
        // 如果提供了路径，尝试检查是否已有权限
        if (directoryPath != null) {
            try {
                // 处理绝对路径的情况
                if (directoryPath.startsWith("/")) {
                    // 检查是否已经有该路径对应的任何持久化权限
                    val permissions = contentResolver.persistedUriPermissions

                    // 尝试找到包含该路径的权限
                    for (permission in permissions) {
                        val documentFile = DocumentFile.fromTreeUri(context, permission.uri)
                        if (documentFile != null && documentFile.canRead() && documentFile.canWrite()) {
                            // 尝试将持久化URI转换为实际路径进行比较
                            val path = getPathFromUri(permission.uri)

                            // 检查请求的路径是否在已授权目录内或者是已授权目录本身
                            if (path != null && path == directoryPath) {
                                resultMap["uri"] = permission.uri.toString()
                                resultMap["path"] = path
                                print("处理绝对路径的情况 有权限")
                                pendingResult?.success(resultMap)
                                pendingResult = null
                                return
                            }
                        }
                    }
                }
                // 处理content://开头的URI
                else if (directoryPath.startsWith("content://")) {
                    val uri = Uri.parse(directoryPath)

                    // 检查是否已经有该URI的持久化权限
                    val hasPermission = contentResolver.persistedUriPermissions.any {
                        it.uri.toString() == uri.toString() &&
                                (it.isReadPermission && it.isWritePermission)
                    }

                    if (hasPermission) {
                        resultMap["uri"] = uri.toString()
                        resultMap["path"] = getPathFromUri(uri)
                        print("处理content://开头的URI 有权限")
                        pendingResult?.success(resultMap)
                        pendingResult = null
                        return
                    }
                }
            } catch (e: Exception) {
                // 错误处理，继续使用选择器
            }
        }

        // 如果没有提供有效路径或没有权限，弹出选择器
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        startActivityForResult(intent, REQUEST_CODE_OPEN_DIRECTORY)
    }

    // 辅助方法：尝试从URI获取实际路径
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

        // 如果没有提供有效URI或没有权限，弹出选择器
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        startActivityForResult(intent, REQUEST_CODE_OPEN_DIRECTORY)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_OPEN_DIRECTORY && resultCode == Activity.RESULT_OK) {
            data?.data?.let { treeUri ->
                val resultMap = HashMap<String, Any?>()
                resultMap["uri"] = treeUri.toString()
                resultMap["path"] = getPathFromUri(treeUri)
                // 获取持久化权限
                val takeFlags =
                    data.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                contentResolver.takePersistableUriPermission(treeUri, takeFlags)
                print(resultMap)
                pendingResult?.success(resultMap)
                pendingResult = null
            }
        } else if (pendingResult != null) {
            pendingResult?.error("CANCELLED", "用户取消了目录选择", null)
            pendingResult = null
        }
    }

    private fun scanFiles(directoryUriString: String, result: MethodChannel.Result) {
        try {
            val directoryUri = Uri.parse(directoryUriString)
            val directory = DocumentFile.fromTreeUri(this, directoryUri)

            if (directory == null || !directory.exists() || !directory.isDirectory) {
                result.error("INVALID_DIRECTORY", "提供的URI不是有效目录", null)
                return
            }

            val filesList = ArrayList<Map<String, Any?>>()

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
            result.error("SCAN_ERROR", "扫描文件时出错: ${e.message}", null)
        }
    }
}

