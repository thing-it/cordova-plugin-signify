package com.thingit.integration.signify

import android.os.AsyncTask
import android.os.Handler
import android.util.Log
import com.philips.indoorpositioning.library.IndoorPositioning
import com.philips.indoorpositioning.library.IndoorPositioning.IndoorPositioningHeadingOrientation
import com.philips.indoorpositioning.library.IndoorPositioning.IndoorPositioningMode
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaPlugin
import org.apache.cordova.PluginResult
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*
import java.util.concurrent.Executors
import java.util.concurrent.ThreadPoolExecutor

class PositioningManager : CordovaPlugin() {

  protected val TAG = "PositioningManager"

  private val debugEnabled = true

  private val threadPoolExecutor = Executors.newFixedThreadPool(10) as ThreadPoolExecutor

  private val handler = Handler()

  lateinit var signifyEventNotifier: ISignifyEventNotifier

  lateinit var indoorPositioning: IndoorPositioning

  @Throws(JSONException::class)
  override fun execute(action: String, data: JSONArray, callbackContext: CallbackContext): Boolean {

      if ("configure".equals(action)) {
        this.configure(data.getString(0), data.getBoolean(1), callbackContext)
      } else if ("start".equals(action)) {
        this.start(callbackContext)
      } else if ("stop".equals(action)) {
        this.stop(callbackContext)
      } else if ("registerDelegateCallbackId".equals(action)) {
        this.registerDelegateCallbackId(data.optJSONObject(0), callbackContext)
      } else {
        return false
      }

      return true
  }

  private fun configure(license: String, testMode: Boolean, callbackContext: CallbackContext) {

    _handleCallSafely(callbackContext, object : ISignifyCommand {

      override fun run(): PluginResult {

        indoorPositioning = IndoorPositioning(cordova.activity.application)
        indoorPositioning.setHeadingOrientation(IndoorPositioningHeadingOrientation.PORTRAIT)
        indoorPositioning.setConfiguration(license)
        indoorPositioning.setMode(
          if (testMode == true) IndoorPositioningMode.SIMULATION else IndoorPositioningMode.DEFAULT
        )

        indoorPositioning.register(indoorPositioningListener, handler)
        indoorPositioning.start()

        return PluginResult(PluginResult.Status.OK);
      }

    }, true)

  }

  private fun start(callbackContext: CallbackContext) {

    _handleCallSafely(callbackContext, object : ISignifyCommand {

      override fun run(): PluginResult {
         if (::indoorPositioning.isInitialized && indoorPositioning.isRunning() == false) {
          indoorPositioning.register(indoorPositioningListener, handler)
          indoorPositioning.start()
         }
        return PluginResult(PluginResult.Status.OK);
      }

    }, true)

  }

  private fun stop(callbackContext: CallbackContext) {

    _handleCallSafely(callbackContext, object : ISignifyCommand {

      override fun run(): PluginResult {
        if (::indoorPositioning.isInitialized && indoorPositioning.isRunning() == true) {
          indoorPositioning.stop()
        }
        indoorPositioning.unregister()
        return PluginResult(PluginResult.Status.OK);
      }

    }, true)

  }

  private val indoorPositioningListener: IndoorPositioning.Listener = object : IndoorPositioning.Listener {

    override fun didUpdateHeading(heading: Map<String, Any>) {
      if (::signifyEventNotifier.isInitialized) {
        signifyEventNotifier.didReceiveHeading(HeadingEvent(heading))
      }
    }

    override fun didUpdateLocation(location: Map<String, Any>) {
      if (::signifyEventNotifier.isInitialized) {
        signifyEventNotifier.didReceiveLocation(LocationEvent(location))
      }
    }

    override fun didFailWithError(error: IndoorPositioning.Listener.Error) {
      if (::signifyEventNotifier.isInitialized) {
        signifyEventNotifier.didReceiveError(ErrorEvent(error.toString()))
      }
    }

  }

  private fun registerDelegateCallbackId(arguments: JSONObject?, callbackContext: CallbackContext) {

      _handleCallSafely(callbackContext, object : ISignifyCommand {

          override fun run(): PluginResult {

              debugLog("Registering delegate callback ID: " + callbackContext.callbackId)

              createNotifierCallbacks(callbackContext)

              val result = PluginResult(PluginResult.Status.OK)
              result.keepCallback = true
              return result
          }
      })

  }

  private fun createNotifierCallbacks(callbackContext: CallbackContext) {

      signifyEventNotifier = object : ISignifyEventNotifier {

        override fun didReceiveError(event: ErrorEvent) {

            threadPoolExecutor.execute(Runnable {
                try {

                    val data = JSONObject()
                    data.put("eventType", "didReceiveError")

                    data.put("event",  event.toJson())

                    //send and keep reference to callback
                    val result = PluginResult(PluginResult.Status.OK, data)
                    result.keepCallback = true
                    callbackContext.sendPluginResult(result)

                } catch (e: Exception) {
                    Log.e(TAG, "'didReceiveError' exception " + e.cause)
                }
            })
        }

        override fun didReceiveLocation(event: LocationEvent) {

          threadPoolExecutor.execute(Runnable {
            try {

              val data = JSONObject()
              data.put("eventType", "didReceiveLocation")

              data.put("event", event.toJson())

              //send and keep reference to callback
              val result = PluginResult(PluginResult.Status.OK, data)
              result.keepCallback = true
              callbackContext.sendPluginResult(result)

            } catch (e: Exception) {
              Log.e(TAG, "'didReceiveLocation' exception " + e.cause)
            }
          })

        }

        override fun didReceiveHeading(event: HeadingEvent) {

          threadPoolExecutor.execute(Runnable {
            try {

              val data = JSONObject()
              data.put("eventType", "didReceiveHeading")

              data.put("event", event.toJson())

              //send and keep reference to callback
              val result = PluginResult(PluginResult.Status.OK, data)
              result.keepCallback = true
              callbackContext.sendPluginResult(result)

            } catch (e: Exception) {
              Log.e(TAG, "'didReceiveHeading' exception " + e.cause)
            }
          })

        }

      }
  }

  private fun _handleCallSafely(callbackContext: CallbackContext, task: ISignifyCommand) {
      _handleCallSafely(callbackContext, task, true)
  }

  private fun _handleCallSafely(callbackContext: CallbackContext, task: ISignifyCommand, runInBackground: Boolean) {

      if (runInBackground) {
          object : AsyncTask<Void, Void, Void>() {

              override fun doInBackground(vararg params: Void): Void? {

                  try {
                      _sendResultOfCommand(callbackContext, task.run())
                  } catch (ex: Exception) {
                      _handleExceptionOfCommand(callbackContext, ex)
                  }

                  return null
              }

          }.execute()
      } else {
          try {
              _sendResultOfCommand(callbackContext, task.run())
          } catch (ex: Exception) {
              _handleExceptionOfCommand(callbackContext, ex)
          }

      }
  }

  private fun _handleExceptionOfCommand(callbackContext: CallbackContext?, exception: Exception) {

      Log.e(TAG, "Uncaught exception: " + exception.message)
      val stackTrace = exception.stackTrace
      val stackTraceElementsAsString = Arrays.toString(stackTrace)
      Log.e(TAG, "Stack trace: $stackTraceElementsAsString")

      // When calling without a callback from the client side the command can be null.
      if (callbackContext == null) {
          return
      }

      callbackContext.error(exception.message)
  }

  private fun _sendResultOfCommand(callbackContext: CallbackContext?, pluginResult: PluginResult) {

      //debugLog("Send result: " + pluginResult.getMessage());
      if (pluginResult.status != PluginResult.Status.OK.ordinal)
          debugWarn("WARNING: " + PluginResult.StatusMessages[pluginResult.status])

      // When calling without a callback from the client side the command can be null.
      if (callbackContext == null) {
          return
      }

      callbackContext.sendPluginResult(pluginResult)
  }

  private fun debugInfo(message: String) {
      if (debugEnabled) {
          Log.i(TAG, message)
      }
  }

  private fun debugLog(message: String) {
      if (debugEnabled) {
          Log.d(TAG, message)
      }
  }

  private fun debugWarn(message: String) {
      if (debugEnabled) {
          Log.w(TAG, message)
      }
  }

}