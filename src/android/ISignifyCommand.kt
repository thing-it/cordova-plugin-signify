package com.thingit.integration.signify

import org.apache.cordova.PluginResult

internal interface ISignifyCommand {
    fun run(): PluginResult
}
