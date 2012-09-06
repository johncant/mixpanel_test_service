Gem::Specification.new do |s|
  s.name = "mixpanel_test_service"
  s.version = "0.0.1"
  s.date = '2012-09-05'
  s.summary = "test your Mixpanel integration"
  s.description = "Mixpanel test service - logs all Mixpanel events sent to it"
  s.authors = "John Cant"
  s.email = "a.johncant@gmail.com"
  s.files = Dir["test/**/*"] + Dir["lib/*"]
  s.homepage =  'http://rubygems.org/gems/mixpanel_test_service'
  s.require_paths = ["lib"]
#  s.add_dependency("net-http-server", :git => "https://github.com/johncant/net-http-server")
  s.add_development_dependency("rspec")
end
