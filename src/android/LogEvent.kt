package com.thingit.integration.signify

import org.json.JSONException
import org.json.JSONObject

import java.util.Date

class LogEvent(val message: String) {

  val timestamp: Date

  init {
    this.timestamp = Date()
  }

  @Throws(JSONException::class)
  fun toJson(): JSONObject {
    val json = JSONObject()
    json.put("message", this.message)
    json.put("timestamp", this.timestamp)
    return json
  }

}
