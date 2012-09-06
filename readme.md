<h1>Mixpanel test service</h2>

<p>
  Logs all events sent to Mixpanel, if you replace the URL of the mixpanel API with the URL of this service.
</p>

<pre>
  test_service = MixpanelTestService.new(:port => 3001)

  // Post some stuff
  MixpanelTestService.transaction do // This gives you thread safe access to test_service
    test_service.events is a normal array containing all submitted events.
  end

  test_service.stop
</pre>

<h2>Dependency problems</h2>
<p>This gem relies on a bug fix that has not been pulled yet</p>

<h2>Waiting for the server to start<h2>
<p>Its now 2am. I made the code sleep for 1 second while the server starts up in a thread.</p>
