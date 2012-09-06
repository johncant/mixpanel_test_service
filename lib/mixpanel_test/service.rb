require 'rubygems'
require 'net/http/server'
require 'thread'
require 'base64'
require 'json'
require 'net/http'

class MixpanelTest::Service

  attr_accessor :events

  public
  def transaction
    @events_mutex.synchronize do
      yield
    end
  end

  def shutdown
    @server.shutdown
  end

  def stopped?
    @server.stopped?
  end

  def stop
    @server.stop
  end

  def initialize(options={})

    @events = []
    @events_mutex = Mutex.new

    @mixpanel_js_cache = {}

#    started = ConditionVariable.new

      puts "Starting server"
# :success_opener => lambda { @events_mutex.synchonize do started.signal end})

      @options = {:port => 3001}.merge(options).merge(:background => true)

      @server = Net::HTTP::Server.run(@options) do |req, stream|
        begin
          puts req[:uri].inspect

          if cached_js = @mixpanel_js_cache[req[:uri][:path].to_s]
            next [200, {'Content-Type' => 'text/html'}, [cached_js]]
          elsif req[:uri][:path].to_s.match(/\/libs\//)
            cached_js = @mixpanel_js_cache[req[:uri][:path].to_s] ||= Net::HTTP.get(URI("http://cdn.mxpnl.com#{req[:uri][:path].to_s}")).gsub('api.mixpanel.com', "localhost:#{options[:port]}")
            next [200, {'Content-Type' => 'text/html'}, [cached_js]]
          else

            # Parse the query string
            query_params = req[:uri][:query].to_s.split('&').map do |s| s.split('=') end.map do |a| {a[0] => a[1]} end.inject(&:merge)

            # Decode the data
            data = Base64.decode64(query_params["data"])

            # Eliminate extemporaneous chars outside the JSON
            data = data.match(/\{.*\}/)[0]

            # Parse with JSON
            data = JSON.parse(data)

            # Save
            transaction do
              @events << data
            end

            next [200, {'Content-Type' => 'text/html'}, [""]]
          end
        rescue Exception => e
          puts $!, *$@
        end
      end


#    @events_mutex.synchronize do
#      started.wait(@events_mutex)
#    end
    # This point can only be reached if the server starts
    puts "Thread started"
    
  end

end
