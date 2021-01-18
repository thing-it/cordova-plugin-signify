package com.thingit.integration.signify

import org.apache.cordova.PluginResult

internal interface IMyPortCommand {
    fun run(): PluginResult
}