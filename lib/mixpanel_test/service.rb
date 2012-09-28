require 'rubygems'
require 'net/http/server'
require File.expand_path('../parser', __FILE__)
require File.expand_path('../analysis', __FILE__)
require 'thread'
require 'json'
require 'net/http'

module MixpanelTest
  class Service
    class PathNotFoundError < StandardError ; end
    class NoDataError < StandardError ; end

    include MixpanelTest::Parser::InstanceMethods

    attr_accessor :events, :people   # The live queue of received events
    attr_writer :log_events # Whether to log all events 
    attr_reader :all_events, :all_people, :all_imported_events # Log of all events

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

    def stop
      puts "Stopping Mixpanel test service"
      @server.stop
      Thread.pass until @server.stopped?
      puts "Mixpanel test server stopped"
    end

    def analysis
      @analysis ||= Analysis.new
      @analysis.add_events(@all_events)
      @analysis
    end

    def initialize(options={})

      @events = []
      @people = []
      @all_events = []
      @all_people = []
      @all_imported_events = []
      @log_events = options[:log_events]
      @log_people = options[:log_people]
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
            query_params = parse_query_params(req[:uri][:query])

            if query_params["data"]
              data = decode_data(query_params["data"])

              if req[:uri][:path].to_s.match(/engage/)

                # Save
                transaction do
                  @people << data
                  @all_people << data if @log_people
                end
              elsif req[:uri][:path].to_s.match(/track/)
                # Save

                transaction do
                  @events << data
                  @all_events << data if @log_events
                end
              elsif req[:uri][:path].to_s.match(/import/)
                transaction do
                  @all_imported_events << data
                end
              else
                raise PathNotFoundError
              end

            else
              raise NoDataError
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
