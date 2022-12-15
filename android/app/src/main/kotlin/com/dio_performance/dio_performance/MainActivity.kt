package com.dio_performance.dio_performance

import android.os.AsyncTask
import android.os.Looper
import androidx.annotation.NonNull
import androidx.core.os.HandlerCompat
import com.squareup.okhttp.Headers
import com.squareup.okhttp.OkHttpClient
import com.squareup.okhttp.Request
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.dio_performance/get"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        val executorService = Executors.newSingleThreadExecutor()
        val mainThreadHandler = HandlerCompat.createAsync(Looper.getMainLooper())
        val client = OkHttpClient()
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "get") {
                executorService.execute {
                    try {
                        val arg = call.arguments as Map<*, *>

                        val request: Request = Request.Builder()
                            .url(arg["url"] as String)
                            .headers(Headers.of(arg["headers"] as Map<String, String>))
                            .build()

                        val response = client.newCall(request).execute()

                        if (response.code() != 200) {
                            mainThreadHandler.post {
                                result.error("error", "some error", "")
                            }
                        } else {
                            val body = response.body().string()
                            mainThreadHandler.post {
                                result.success(body)
                            }
                        }
                    } catch (error: Exception) {
                        result.error("error", error.toString(), "")
                    }
                }
            } else if (call.method == "constantString") {
                result.success("Quisque et diam nunc. Praesent a euismod mi. Nam ante nibh, luctus non leo quis, dapibus ultrices elit. Sed nec orci sapien. Sed id maximus risus, quis blandit ligula. Etiam in feugiat sapien. Etiam nec vehicula sapien. Fusce porta magna vel venenatis venenatis. Donec non ex laoreet, dictum dui a, laoreet augue. Ut vehicula lorem purus, ultrices aliquet lacus pharetra in. Nullam vitae fermentum ligula, semper dapibus sapien. Ut mauris nisl, congue tincidunt metus eu, interdum tincidunt ex.")
            }
        }
    }
}
