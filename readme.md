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

<h2>Known issues</h2>
<p>Sometimes, this gem gives me the following errors which come from net-http-server itself.</p>

<pre>
[Wed Sep 12 20:22:08 2012] /home/john/.rvm/gems/ruby-1.9.2-p290/gems/net-http-server-0.2.2/lib/net/http/server/responses.rb:98:in `write'
/home/john/.rvm/gems/ruby-1.9.2-p290/gems/net-http-server-0.2.2/lib/net/http/server/responses.rb:98:in `block (2 levels) in write_headers'
/home/john/.rvm/gems/ruby-1.9.2-p290/gems/net-http-server-0.2.2/lib/net/http/server/responses.rb:97:in `each_line'
/home/john/.rvm/gems/ruby-1.9.2-p290/gems/net-http-server-0.2.2/lib/net/http/server/responses.rb:97:in `block in write_headers'
/home/john/.rvm/gems/ruby-1.9.2-p290/gems/net-http-server-0.2.2/lib/net/http/server/responses.rb:94:in `each'
/home/john/.rvm/gems/ruby-1.9.2-p290/gems/net-http-server-0.2.2/lib/net/http/server/responses.rb:94:in `write_headers'
/home/john/.rvm/gems/ruby-1.9.2-p290/gems/net-http-server-0.2.2/lib/net/http/server/responses.rb:166:in `write_response'
/home/john/.rvm/gems/ruby-1.9.2-p290/gems/net-http-server-0.2.2/lib/net/http/server/daemon.rb:124:in `serve'
/home/john/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/gserver.rb:211:in `block (2 levels) in start'
</pre>

<p>It appears these errors are caused by the connection being closed before mixpanel_test_service has finished its response. For instance, this might be caused by instrumenting a submit button without delaying the form submit. The page will change, canceling the AJAX halfway through, and causing</p>
