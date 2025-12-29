package com.sms.reading_sms

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.net.toUri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.myapp/sms"
    private val SMS_PERMISSION_CODE = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // ✅ جلب رسائل شخص معين
                    "getSMSByContact" -> {
                        if (checkPermission()) {
                            val phoneNumber = call.argument<String>("phoneNumber")
                            if (phoneNumber != null) {
                                val smsList = getSMSByContact(phoneNumber)
                                result.success(smsList)
                            } else {
                                result.error("INVALID_ARGUMENT", "Phone number is required", null)
                            }
                        } else {
                            requestPermission()
                            result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                        }
                    }

                    // ✅ جلب جميع المحادثات
                    "getConversations" -> {
                        if (checkPermission()) {
                            val conversations = getAllConversations()
                            result.success(conversations)
                        } else {
                            requestPermission()
                            result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                        }
                    }

                    // الطريقة القديمة (جميع الرسائل)
                    "getSMS" -> {
                        if (checkPermission()) {
                            val smsList = getAllSMS()
                            result.success(smsList)
                        } else {
                            requestPermission()
                            result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                        }
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun checkPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_SMS
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.READ_SMS),
            SMS_PERMISSION_CODE
        )
    }

    // ✅ جلب رسائل شخص معين
    private fun getSMSByContact(phoneNumber: String): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()

        try {
            val uri = "content://sms".toUri()
            val projection = arrayOf("address", "body", "date", "type")

            // ✅ فلترة حسب الرقم
            val selection = "address = ?"
            val selectionArgs = arrayOf(phoneNumber)

            val cursor: Cursor? = contentResolver.query(
                uri,
                projection,
                selection,
                selectionArgs,
                "date DESC"
            )

            cursor?.use {
                while (it.moveToNext()) {
                    val sender = it.getString(it.getColumnIndexOrThrow("address"))
                    val body = it.getString(it.getColumnIndexOrThrow("body"))
                    val date = it.getLong(it.getColumnIndexOrThrow("date"))
                    val type = it.getInt(it.getColumnIndexOrThrow("type"))

                    smsList.add(
                        mapOf(
                            "sender" to sender,
                            "body" to body,
                            "date" to date,
                            "type" to type  // 1=inbox, 2=sent, 3=draft
                        )
                    )
                }
            }

        } catch (e: Exception) {
            e.printStackTrace()
        }

        return smsList
    }

    // ✅ جلب جميع المحادثات (Grouped by phone number)
    private fun getAllConversations(): List<Map<String, Any>> {
        val conversationsMap = mutableMapOf<String, MutableMap<String, Any>>()

        try {
            val uri = "content://sms".toUri()
            val projection = arrayOf("address", "body", "date", "type")

            val cursor: Cursor? = contentResolver.query(
                uri,
                projection,
                null,
                null,
                "date DESC"
            )

            cursor?.use {
                while (it.moveToNext()) {
                    val address = it.getString(it.getColumnIndexOrThrow("address"))
                    val body = it.getString(it.getColumnIndexOrThrow("body"))
                    val date = it.getLong(it.getColumnIndexOrThrow("date"))

                    // إذا لم يكن موجود، أضفه
                    if (!conversationsMap.containsKey(address)) {
                        conversationsMap[address] = mutableMapOf(
                            "phoneNumber" to address,
                            "lastMessage" to body,
                            "lastDate" to date,
                            "messageCount" to 1
                        )
                    } else {
                        // زيادة العدد
                        val count = conversationsMap[address]!!["messageCount"] as Int
                        conversationsMap[address]!!["messageCount"] = count + 1
                    }
                }
            }

        } catch (e: Exception) {
            e.printStackTrace()
        }

        return conversationsMap.values.toList()
    }

    // الطريقة القديمة (جميع الرسائل)
    private fun getAllSMS(): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()

        try {
            val uri = "content://sms/inbox".toUri()
            val projection = arrayOf("address", "body", "date")

            val cursor: Cursor? = contentResolver.query(
                uri,
                projection,
                null,
                null,
                "date DESC"
            )

            cursor?.use {
                while (it.moveToNext()) {
                    val sender = it.getString(it.getColumnIndexOrThrow("address"))
                    val body = it.getString(it.getColumnIndexOrThrow("body"))
                    val date = it.getLong(it.getColumnIndexOrThrow("date"))

                    smsList.add(
                        mapOf(
                            "sender" to sender,
                            "body" to body,
                            "date" to date
                        )
                    )
                }
            }

        } catch (e: Exception) {
            e.printStackTrace()
        }

        return smsList
    }
}