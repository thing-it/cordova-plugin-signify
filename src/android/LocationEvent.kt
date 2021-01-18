package com.thingit.integration.signify

import org.json.JSONException
import org.json.JSONObject

import com.philips.indoorpositioning.library.IndoorPositioning
import com.philips.indoorpositioning.library.IndoorPositioning.Listener.ExpectedAccuracyLevel

class LocationEvent(location: Map<String, Any>) {

    val latitude: Double
    val longitude: Double
    val horizontalAccuracy: Float
    val altitude: Double
    val verticalAccuracy: Float
    val floor: Int
    val accuracyLevel: Int
    val expectedAccuracyLevel:String

    init {
        this.latitude = location[IndoorPositioning.Listener.LOCATION_LATITUDE] as Double
        this.longitude = location[IndoorPositioning.Listener.LOCATION_LONGITUDE] as Double
        this.horizontalAccuracy = location[IndoorPositioning.Listener.LOCATION_HORIZONTAL_ACCURACY] as Float
        this.altitude = location[IndoorPositioning.Listener.LOCATION_ALTITUDE] as Double
        this.verticalAccuracy = location[IndoorPositioning.Listener.LOCATION_VERTICAL_ACCURACY] as Float
        this.floor = location[IndoorPositioning.Listener.LOCATION_FLOOR_LEVEL] as Int
        this.accuracyLevel = location[IndoorPositioning.Listener.LOCATION_EXPECTED_ACCURACY_LEVEL] as? Int ?: 0

        this.expectedAccuracyLevel = ExpectedAccuracyLevel.fromInteger(this.accuracyLevel).toString();
    }

    @Throws(JSONException::class)
    fun toJson(): JSONObject {

        val json = JSONObject()

       json.put("latitude", this.latitude)
        json.put("longitude", this.longitude)
        json.put("horizontalAccuracy", this.horizontalAccuracy)
        json.put("altitude", this.altitude)
        json.put("verticalAccuracy", this.verticalAccuracy)
        json.put("floor", this.floor)
        json.put("accuracyLevel", this.accuracyLevel)
        json.put("expectedAccuracyLevel", this.expectedAccuracyLevel)

        return json
    }

}
