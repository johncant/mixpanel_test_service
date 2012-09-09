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

<h2>Rerouting Mixpanel requests to mixpanel_test_service</h2>

<p>mixpanel_test_service proxies the js file from Mixpanel, caches it locally, and edits the mixpanel API url. The mixpanel API hostname gets replaced by localhost:3001 or whatever port we are running on, so if the script is run on a webpage, then all the Mixpanel API calls go to this service instead. All you have to do is load the script from the running mixpanel_test_service instead of the Mixpanel CDN. Use the same path
</p>

<h2>Limitations</h2>
<p>This gem proxies the mixpanel JS API file, but it does not distribute it. You will need internet to run your tests.</p>
