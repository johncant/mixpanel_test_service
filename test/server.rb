require "./lib/mixpanel_test"
require "./lib/mixpanel_test/service"
require "uri"
require "net/http"
require 'pry'

TEST_PORT = 3001

begin
  Net::HTTP.get(URI("http://localhost:#{TEST_PORT}"))
  puts "Someone already listening on port #{TEST_PORT}"
  exit(0)
rescue
  # Good
end

service = MixpanelTest::Service.new(:port => TEST_PORT)

pry
