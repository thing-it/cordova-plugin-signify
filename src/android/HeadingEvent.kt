package com.thingit.integration.signify

import org.json.JSONException
import org.json.JSONObject

import com.philips.indoorpositioning.library.IndoorPositioning

class HeadingEvent(heading: Map<String, Any>) {

    val headingDegrees: Float
    val headingAccuracy: Float
    val headingArbitraryNorthDegrees: Float

    init {
        this.headingDegrees = heading[IndoorPositioning.Listener.HEADING_DEGREES] as Float
        this.headingAccuracy = heading[IndoorPositioning.Listener.HEADING_ACCURACY] as Float
        this.headingArbitraryNorthDegrees = heading[IndoorPositioning.Listener.HEADING_ARBITRARY_NORTH_DEGREES] as Float
    }

    @Throws(JSONException::class)
    fun toJson(): JSONObject {

        val json = JSONObject()

        json.put("headingDegrees", this.headingDegrees)
        json.put("headingAccuracy", this.headingAccuracy)
        json.put("headingArbitraryNorthDegrees", this.headingArbitraryNorthDegrees)

        return json
    }

}