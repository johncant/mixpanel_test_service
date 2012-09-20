require 'base64'
require 'uri'
require 'json'

module MixpanelTest

  class Parser

    module InstanceMethods

      # Extract the query parameters as a hash from the query string
      def parse_query_params(qs)
        qs.to_s.split('&').map do |s| s.split('=') end.map do |a| {URI.unescape(a[0]) => URI.unescape(a[1])} end.inject(&:merge) || {}
      end

      # Decode the data string.
      def decode_data(encoded_data)

        # Decode the data
        data = Base64.decode64(encoded_data)

        # Eliminate extemporaneous chars outside the JSON
        data = data.match(/\{.*\}/)[0]

        # Parse with JSON
        data = JSON.parse(data)

      end

      def decode_cookie(cookie)

        #begin
        # split cookie and find a mixpanel section
        section = cookie.split('; ').find do |tok| tok.match(/^mp_/) end;

        # Decode and find json
        data = URI.unescape(section).match(/\{.*\}/)[0]

        # Parse as JSON
        JSON.parse(data)

        #rescue

          # raise BadCookieError, but first, figure out how to test this functionality

        #end
      end

    end

    extend InstanceMethods

  end

end
