package com.thingit.integration.signify

interface ISignifyEventNotifier {

  fun didReceiveError(event: ErrorEvent)
  fun didReceiveLocation(location: LocationEvent)
  fun didReceiveHeading(heading: HeadingEvent)

}
