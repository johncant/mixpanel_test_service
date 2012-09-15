require 'rubygems'
require 'net/http/server'
require 'thread'
require 'base64'
require 'json'
require 'net/http'

module MixpanelTest
  class Service

    attr_accessor :events   # The live queue of received events
    attr_writer :log_events # Whether to log all events 
    attr_reader :all_events # Log of all events

    @@js_headers = {'Connection' => "keep-alive", "Content-Type" => "application/x-javascript", "Transfer-Encoding" => "chunked", 'Cache-Control' => 'max-age=86400'}
    @@api_headers = {
      "Access-Control-Allow-Headers" => "X-Requested-With", 
      "Access-Control-Allow-Methods" => "GET, POST, OPTIONS", 
      "Access-Control-Allow-Origin" => "*", 
      "Access-Control-Max-Age" => "1728000", 
      "Cache-Control" => "no-cache, no-store", 
      "Connection" => "close", 
      "Content-Type" => "application/json"}

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
      @all_events = []
      @log_events = options[:log_events]
      @events_mutex = Mutex.new

      @mixpanel_js_cache = {}

      @options = {:port => 3001}.merge(options).merge(:background => true)

      @server = Net::HTTP::Server.run(@options) do |req, stream|

        begin

          if cached_js = @mixpanel_js_cache[req[:uri][:path].to_s]
            next [200, @@js_headers, [cached_js]]
          elsif req[:uri][:path].to_s.match(/\/libs\//)
            #puts "PATH: #{puts req[:uri][:path]}"
            cached_js = @mixpanel_js_cache[req[:uri][:path].to_s] ||= Net::HTTP.get(URI("http://cdn.mxpnl.com#{req[:uri][:path].to_s}")).gsub('api.mixpanel.com', "localhost:#{options[:port]}")
            next [200, @@js_headers, [cached_js]]
          else

            # Parse the query string
            query_params = req[:uri][:query].to_s.split('&').map do |s| s.split('=') end.map do |a| {a[0] => a[1]} end.inject(&:merge) || {}


            if query_params["data"]

              # Decode the data
              data = Base64.decode64(URI.unescape(query_params["data"]))

              # Eliminate extemporaneous chars outside the JSON
              data = data.match(/\{.*\}/)[0]

              # Parse with JSON
              data = JSON.parse(data)

              # Save
              transaction do
                @events << data
              end

              @all_events << data if @log_events

            else
  #              puts "No data. #{req[:uri].inspect}"
            end

            next [200, @@api_headers, ["1"]]
          end
        rescue Exception => e
          puts $!, *$@
        end
      end

    end

  end

end
