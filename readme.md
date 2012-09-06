<h1>Mixpanel test service</h2>

<p>
  Logs all events sent to Mixpanel, if you replace the URL of the mixpanel API with the URL of this service.
</p>

<pre>
  require "mixpanel_test/service"

  test_service = MixpanelTestService.new(:port => 3001)

  // Post some stuff
  MixpanelTestService.transaction do // This gives you thread safe access to test_service
    test_service.events is a normal array containing all submitted events.
  end

  test_service.stop
</pre>

<h2>Dependency problems</h2>
<p>This gem relies on a bug fix that in net-http-server which has not yet been published</p>
