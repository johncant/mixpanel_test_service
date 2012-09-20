require "./lib/mixpanel_test"
require "./lib/mixpanel_test/service"
require "uri"
require "net/http"
require "rspec"

TEST_PORT = 3004

describe MixpanelTest::Service do

  before(:all) do

    lambda {
      Net::HTTP.get(URI("http://localhost:#{TEST_PORT}"))
    }.should raise_error Errno::ECONNREFUSED

    @service = MixpanelTest::Service.new(:port => TEST_PORT, :log_events => true, :log_people => true)

    @service.should_not == nil

    @service.transaction do
      @service.events.should == []
    end
    @service.all_events.should == []

  end

  it "should parse a Mixpanel event" do

    uri = URI.parse("http://localhost:#{TEST_PORT}/track?data=eyJldmVudCI6ICJ0ZXN0LWV2ZW50IiwicHJvcGVydGllcyI6IHsiJG9zIjogIkxpbnV4IiwiJGJyb3dzZXIiOiAiQ2hyb21lIiwiJHJlZmVycmVyIjogIiIsIiRyZWZlcnJpbmdfZG9tYWluIjogIiIsImRpc3RpbmN0X2lkIjogImZvbyIsIiRpbml0aWFsX3JlZmVycmVyIjogImh0dHA6Ly9sb2NhbGhvc3Q6MzAwMC9qb2JzIiwiJGluaXRpYWxfcmVmZXJyaW5nX2RvbWFpbiI6ICJsb2NhbGhvc3Q6MzAwMCIsIm1wX25hbWVfdGFnIjogInRlc3RfdXNlciIsIm5ld19kYXRhIjogImludGVyZXN0aW5nMSIsImZvbyI6ICJiYXIiLCJ0b2tlbiI6ICI0NzE1YzA2NTJkMmRhY2Y3YWY4NTI5NTc3YzYxNTViMyIsInRpbWUiOiAxMzQ2ODY1MDA1fX0%3D&ip=1&test=1&_=1346865005357")

    conn = Net::HTTP.new(uri.host, uri.port)
    resp = conn.request_get("#{uri.path}?#{uri.query}")

    resp.code.to_i.should == 200

    puts resp.body

    @service.transaction do
      @service.events.count.should == 1
    end
    @service.all_events.count.should == 1

  end

  it "should receive Mixpanel people data" do
    
    uri = URI.parse("http://localhost:#{TEST_PORT}/engage?data=eyJldmVudCI6ICJ0ZXN0LWV2ZW50IiwicHJvcGVydGllcyI6IHsiJG9zIjogIkxpbnV4IiwiJGJyb3dzZXIiOiAiQ2hyb21lIiwiJHJlZmVycmVyIjogIiIsIiRyZWZlcnJpbmdfZG9tYWluIjogIiIsImRpc3RpbmN0X2lkIjogImZvbyIsIiRpbml0aWFsX3JlZmVycmVyIjogImh0dHA6Ly9sb2NhbGhvc3Q6MzAwMC9qb2JzIiwiJGluaXRpYWxfcmVmZXJyaW5nX2RvbWFpbiI6ICJsb2NhbGhvc3Q6MzAwMCIsIm1wX25hbWVfdGFnIjogInRlc3RfdXNlciIsIm5ld19kYXRhIjogImludGVyZXN0aW5nMSIsImZvbyI6ICJiYXIiLCJ0b2tlbiI6ICI0NzE1YzA2NTJkMmRhY2Y3YWY4NTI5NTc3YzYxNTViMyIsInRpbWUiOiAxMzQ2ODY1MDA1fX0%3D&ip=1&test=1&_=1346865005357")

    conn = Net::HTTP.new(uri.host, uri.port)
    resp = conn.request_get("#{uri.path}?#{uri.query}")

    resp.code.to_i.should == 200

    puts resp.body

    @service.transaction do
      @service.people.count.should == 1
    end
    @service.all_people.count.should == 1

  end

  it "should fetch a modified mixpanel javascript API" do
    js = Net::HTTP.get(URI("http://localhost:#{TEST_PORT}/libs/mixpanel-2.0.min.js"))
    js.should match /function/
    js.should match /localhost:#{TEST_PORT}/
  end

  it "should cache the modified mixpanel javascript API" do
    js = Net::HTTP.get(URI("http://localhost:#{TEST_PORT}/libs/mixpanel-2.0.min.js"))
    # TODO - prevent MixpanelTestService from accessing the internet itself:
    js = Net::HTTP.get(URI("http://localhost:#{TEST_PORT}/libs/mixpanel-2.0.min.js"))
    js.should match /function/
    js.should match /localhost:#{TEST_PORT}/
  end

  after(:all) do

    @service.stop

    Thread.pass until @service.stopped?

    @service.stopped?.should == true

  end

end
