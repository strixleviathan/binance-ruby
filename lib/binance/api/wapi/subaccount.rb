module Binance
  module Api
    module Wapi
      module Subaccount
        class << self
          def list!(recvWindow: nil)
            params = {
              recvWindow: recvWindow, timestamp: timestamp
            }.delete_if { |key, value| value.nil? }

            path = "/wapi/v3/sub-account/list.html"
            Request.send!(api_key_type: :trading, method: :get, path: path,
                          params: params, security_type: :withdraw)
          end

          def history!(email: nil, startTime: nil, endTime: nil, page: nil, limit: nil, recvWindow: nil)
            params = {
              email: email, startTime: startTime, endTime: endTime, page: page, limit: limit,
              recvWindow: recvWindow, timestamp: timestamp
            }.delete_if { |key, value| value.nil? }

            path = "/wapi/v3/sub-account/transfer/history.html"
            Request.send!(api_key_type: :trading, method: :get, path: path,
                          params: params, security_type: :withdraw)
          end

          def assets!(email: nil, symbol: nil, recvWindow: nil)
            params = {
              email: email, symbol: symbol,
              recvWindow: recvWindow, timestamp: timestamp
            }.delete_if { |key, value| value.nil? }

            ensure_required_keys!(params: params, required_keys: %i[email])

            path = "/wapi/v3/sub-account/assets.html"
            Request.send!(api_key_type: :trading, method: :get, path: path,
                          params: params, security_type: :withdraw)
          end

          def transfer!(fromEmail: nil, toEmail: nil, asset: nil, amount: nil, recvWindow: nil)
            params = {
              fromEmail: fromEmail, toEmail: toEmail, asset: asset, amount: amount,
              recvWindow: recvWindow, timestamp: timestamp
            }.delete_if { |key, value| value.nil? }

            ensure_required_keys!(params: params, required_keys: %i[fromEmail toEmail asset amount])

            path = "/wapi/v3/sub-account/transfer.html"
            Request.send!(api_key_type: :trading, method: :post, path: path,
                          params: params, security_type: :withdraw, post_with_query_args: true)
          end

          private def ensure_required_keys!(params:, required_keys:)
            missing_keys = required_keys.select { |key| params[key].nil? }
            raise Error.new(message: "required keys are missing: #{missing_keys.join(', ')}") unless missing_keys.empty?
          end

          private def timestamp
            Binance::Api::Configuration.timestamp
          end
        end
      end
    end
  end
end
