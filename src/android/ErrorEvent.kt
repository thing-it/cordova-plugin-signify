package com.thingit.integration.signify

import org.json.JSONException
import org.json.JSONObject

import java.util.Date

class ErrorEvent(val errorMessage: String) {

    val timestamp: Date

    init {
        this.timestamp = Date()
    }

    @Throws(JSONException::class)
    fun toJson(): JSONObject {
        val json = JSONObject()
        json.put("errorMessage", this.errorMessage)
        json.put("timestamp", this.timestamp)
        return json
    }

}