package com.akash.www.networkconnectivity

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.text.format.Formatter
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.net.NetworkInterface
import java.net.SocketException


class NetworkConnectivityPlugin(var registrar: Registrar) : MethodCallHandler, EventChannel.StreamHandler {
    private var receiver: BroadcastReceiver? = null

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "network_connectivity")
            val eventChannel = EventChannel(registrar.messenger(), "network_connectivity_state")
            channel.setMethodCallHandler(NetworkConnectivityPlugin(registrar))
            eventChannel.setStreamHandler(NetworkConnectivityPlugin(registrar))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method.equals("getconnectivity")) {
            val connectivity = registrar.context().getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            if (connectivity != null) {
                val info = connectivity.allNetworkInfo
                if (info != null)
                    for (i in info.indices)
                        if (info[i].state == NetworkInfo.State.CONNECTED) {
                            result.success(true)
                        }
            } else {
                result.success(false)
            }
        } else if (call.method.equals("getipaddress")) {
            try {
                val en = NetworkInterface.getNetworkInterfaces()
                while (en.hasMoreElements()) {
                    val intf = en.nextElement()
                    val enumIpAddr = intf.getInetAddresses()
                    while (enumIpAddr.hasMoreElements()) {
                        val inetAddress = enumIpAddr.nextElement()
                        if (!inetAddress.isLoopbackAddress()) {
                            val ip = Formatter.formatIpAddress(inetAddress.hashCode())
                            result.success(ip.toString())
                        }
                    }
                }
            } catch (ex: SocketException) {
                ex.stackTrace
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
        receiver = createChargingStateChangeReceiver(p1)
        registrar.context()!!.registerReceiver(receiver!!, IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION))
    }

    private fun createChargingStateChangeReceiver(p1: EventChannel.EventSink?): BroadcastReceiver? {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val isLost = intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false)
                if (isLost) {
                    p1!!.success("0")
                    return
                } else {
                    p1!!.success("200")
                }
            }
        }
    }

    override fun onCancel(p0: Any?) {
        registrar.context().unregisterReceiver(receiver)
        receiver = null
    }
}
