package com.systemvpn

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Service
import android.content.Intent
import android.net.VpnService
import android.util.Log
import androidx.annotation.Nullable

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.facebook.react.module.annotations.ReactModule

import com.facebook.react.bridge.ActivityEventListener
import com.facebook.react.bridge.BaseActivityEventListener
import com.facebook.fbreact.specs.NativeSystemVpnSpec

@ReactModule(name = SystemVpnModule.NAME)
class SystemVpnModule(reactContext: ReactApplicationContext) :
  NativeSystemVpnSpec(reactContext) {

  @SuppressLint("StaticFieldLeak")
  private val reactContext = reactContext
  
  private val REQUEST_VPN_PERMISSION = 0

  override fun getName(): String {
    return NAME
  }

  private fun sendEvent(eventName: String, params: WritableMap?) {
    reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  override fun prepare(promise: Promise) {
    val currentActivity = currentActivity
    if (currentActivity == null) {
      promise.reject("E_ACTIVITY_DOES_NOT_EXIST", "Activity doesn't exist")
      return
    }

    val intent = VpnService.prepare(currentActivity)
    if (intent != null) {
      val activityEventListener = object : BaseActivityEventListener() {
        override fun onActivityResult(activity: Activity?, requestCode: Int, resultCode: Int, data: Intent?) {
          if (requestCode == REQUEST_VPN_PERMISSION) {
            if (resultCode == Activity.RESULT_OK) {
              promise.resolve(null)
            } else {
              promise.reject("PrepareError", "Failed to prepare VPN")
            }
            reactContext.removeActivityEventListener(this)
          }
        }
      }
      reactContext.addActivityEventListener(activityEventListener)
      currentActivity.startActivityForResult(intent, REQUEST_VPN_PERMISSION)
    } else {
      promise.resolve(null)
    }
  }

  override fun connect(
    config: ReadableMap,
    address: String,
    username: String,
    password: String,
    secret: String,
    disconnectOnSleep: Boolean,
    promise: Promise
  ) {
    val currentActivity = currentActivity
    if (currentActivity == null) {
      promise.reject("E_ACTIVITY_DOES_NOT_EXIST", "Activity doesn't exist")
      return
    }

    val intent = VpnService.prepare(currentActivity)
    if (intent != null) {
      promise.reject("PrepareError", "VPN not prepared")
      return
    }

    try {
      // This is a simplified implementation
      // In a real implementation, you would integrate with a VPN library like StrongSwan
      Log.d(NAME, "Connecting to VPN: $address with username: $username")
      
      // Send connecting state
      val params = Arguments.createMap()
      params.putInt("state", 2) // connecting
      params.putInt("charonState", 0) // no error
      sendEvent("stateChanged", params)
      
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("ConnectError", "Failed to connect to VPN", e)
    }
  }

  override fun saveConfig(
    config: ReadableMap,
    address: String,
    username: String,
    password: String,
    secret: String,
    promise: Promise
  ) {
    try {
      Log.d(NAME, "Saving VPN config for: $address")
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("SaveConfigError", "Failed to save VPN config", e)
    }
  }

  override fun getCurrentState(promise: Promise) {
    try {
      // Return disconnected state by default
      promise.resolve(1)
    } catch (e: Exception) {
      promise.reject("GetStateError", "Failed to get VPN state", e)
    }
  }

  override fun getCharonErrorState(promise: Promise) {
    try {
      // Return no error by default
      promise.resolve(0)
    } catch (e: Exception) {
      promise.reject("GetErrorStateError", "Failed to get error state", e)
    }
  }

  override fun getConnectionTimeSecond(promise: Promise) {
    try {
      // Return 0 seconds by default
      promise.resolve(0)
    } catch (e: Exception) {
      promise.reject("GetConnectionTimeError", "Failed to get connection time", e)
    }
  }

  override fun disconnect(promise: Promise) {
    try {
      Log.d(NAME, "Disconnecting VPN")
      
      // Send disconnected state
      val params = Arguments.createMap()
      params.putInt("state", 1) // disconnected
      params.putInt("charonState", 0) // no error
      sendEvent("stateChanged", params)
      
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("DisconnectError", "Failed to disconnect VPN", e)
    }
  }

  override fun clearKeychainRefs(promise: Promise) {
    try {
      Log.d(NAME, "Clearing keychain references")
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("ClearKeychainError", "Failed to clear keychain refs", e)
    }
  }

  override fun addListener(eventName: String) {
    // Required for EventEmitter
  }

  override fun removeListeners(count: Double) {
    // Required for EventEmitter
  }

  companion object {
    const val NAME = "SystemVpn"
  }
}
