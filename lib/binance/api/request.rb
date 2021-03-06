module Binance
  module Api
    class Request
      include HTTParty

      # Skip the URI serialization provided by HTTParty, it breaks Binance's WAPI
      query_string_normalizer proc { |query|
        query.map do |key, value|
          [value].flatten.map {|v| "#{key}=#{v}"}.join('&')
        end.join('&')
      }

      base_uri 'https://api.binance.com'

      class << self
        def send!(api_key_type: :none, headers: {}, method: :get, path: '/', params: {}, security_type: :none, post_with_query_args: false)
          raise Error.new(message: "invalid security type #{security_type}") unless security_types.include?(security_type)
          all_headers = default_headers(api_key_type: api_key_type, security_type: security_type)
          params.delete_if { |k, v| v.nil? }
          params.merge!(signature: signed_request_signature(params: params)) \
            if [:trade, :user_data, :withdraw].include?(security_type)
          # send() is insecure so don't use it.
          case method
          when :get
            response = get(path, headers: all_headers, query: params)
          when :post
            response = if post_with_query_args
                         post(path, query: params, headers: all_headers)
                       else
                         post(path, body: params, headers: all_headers)
                       end
          when :put
            response = put(path, body: params, headers: all_headers)
          when :delete
            response = delete(path, body: params, headers: all_headers)
          else
            raise Error.new(message: "invalid http method used: #{method}")
          end
          process!(response: response || '{}')
        rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET => error
          raise Error.new(message: "Binance connection error: #{error.class.to_s} - #{error.to_s}"), cause: error
        end

        private

        def default_headers(api_key_type:, security_type:)
          headers = {}
          headers['Content-Type'] = 'application/json; charset=utf-8'
          headers['X-MBX-APIKEY'] = Configuration.api_key(type: api_key_type) unless security_type == :none
          headers
        end

        def process!(response:)
          json = JSON.parse(response.body, symbolize_names: true)
          raise Error.new(json: json) if Error.is_error_response?(response: response)
          json
        rescue JSON::ParserError
          raise Error.new(message: 'Invalid JSON received from Binance')
        end

        def security_types
          [:none, :trade, :user_data, :user_stream, :market_data, :withdraw].freeze
        end

        def signed_request_signature(params:)
          payload = params.map { |key, value| "#{key}=#{value}" }.join('&')
          Configuration.signed_request_signature(payload: payload)
        end
      end
    end
  end
end
