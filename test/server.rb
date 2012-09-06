require "./lib/mixpanel_test"
require "./lib/mixpanel_test/service"
require "uri"
require "net/http"

TEST_PORT = 3004

begin
  Net::HTTP.get(URI("http://localhost:#{TEST_PORT}"))
  puts "Someone already listening on port 3004"
  exit(0)
rescue
  # Good
end

@service = MixpanelTest::Service.new(:port => TEST_PORT)

sleep 100000

