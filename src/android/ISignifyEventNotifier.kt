package com.thingit.integration.signify

interface ISignifyEventNotifier {

  fun didReceiveLog(event: LogEvent)
  fun didReceiveError(event: ErrorEvent)
  fun didReceiveLocation(location: LocationEvent)
  fun didReceiveHeading(heading: HeadingEvent)

}
