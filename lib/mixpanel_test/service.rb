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

  def initialize(options={})

    @events = []
    @events_mutex = Mutex.new

    puts "Starting thread"

#    started = ConditionVariable.new

    Thread.new do
      puts "Starting server"
# :success_opener => lambda { @events_mutex.synchonize do started.signal end})
      Net::HTTP::Server.run(options) do |req, stream|
        begin

          # Parse the query string
          query_params = req[:uri][:query].to_s.split('&').map do |s| s.split('=') end.map do |a| {a[0] => a[1]} end.inject(&:merge)

          unless query_params[:ignore]
            # Decode the data
            data = Base64.decode64(query_params["data"])

            # Eliminate extemporaneous chars outside the JSON
            data = data.match(/{.*}/)[0]

            # Parse with JSON
            data = JSON.parse(data)

            # Save
            transaction do
              @events << data
            end
          end

          next [200, {'Content-Type' => 'text/html'}, [""]]
        rescue Exception => e
          puts $!, *$@
        end
      end

    end

#    @events_mutex.synchronize do
#      started.wait(@events_mutex)
#    end
    # This point can only be reached if the server starts
    sleep 1
    puts "Thread started"
    
  end

end
