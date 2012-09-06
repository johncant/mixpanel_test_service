<h1>Mixpanel test service</h2>

<p>
  Logs all events sent to Mixpanel, if you replace the URL of the mixpanel API with the URL of this service.
</p>

<pre>
  require "mixpanel_test/service"

  test_service = MixpanelTestService.new(:port => 3001)

  // The main purpose:
  // Post some stuff
  MixpanelTestService.transaction do // This gives you thread safe access to test_service
    test_service.events is a normal array containing all submitted events.
  end

  test_service.stop

  // Make the Mixpanel JS API post to this service instead of api.mixpanel.com
$ curl localhost:3001/libs/mixpanel-2.0.min.js # Or any other file in /libs

</pre>

<p>Proxies the js file from Mixpanel, caches it locally, and edits it. The mixpanel API hostname gets replaced by localhost:3001 or whatever port we are running on, so if the script is run on a webpage, then all the Mixpanel API calls go to this service instead.
</p>

<h2></h2>

<h2>Dependency problems</h2>
<p>This gem relies on a bug fix that in net-http-server which has not yet been published</p>
