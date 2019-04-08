module Binance
  module Api
    module Wapi
      class << self
        def withdraw!(asset: nil, address: nil, addressTag: nil, amount: nil, name: nil, recvWindow: nil)
          timestamp = Binance::Api::Configuration.timestamp
          params = {
            asset: asset, address: address,
            addressTag: addressTag, amount: amount, name: name,
            recvWindow: recvWindow, timestamp: timestamp
          }.delete_if { |key, value| value.nil? }

          ensure_required_keys!(params: params, required_keys: [:asset, :address, :amount, :timestamp])

          path = "/wapi/v3/withdraw.html"
          Request.send!(api_key_type: :trading, method: :post, path: path,
                        params: params, security_type: :withdraw)
        end

        def deposit_history(asset: nil)
          timestamp = Binance::Api::Configuration.timestamp
          params = {
            asset: asset
          }.delete_if { |key, value| value.nil? }

          path = "/wapi/v3/depositHistory.html"
          Request.send!(api_key_type: :trading, method: :get, path: path,
                        params: params, security_type: :withdraw)

        end

        def withdraw_history(asset: nil)
          timestamp = Binance::Api::Configuration.timestamp
          params = {
            asset: asset
          }.delete_if { |key, value| value.nil? }

          path = "/wapi/v3/withdrawHistory.html"
          Request.send!(api_key_type: :trading, method: :get, path: path,
                        params: params, security_type: :withdraw)

        end

        private def ensure_required_keys!(params:, required_keys:)
          missing_keys = required_keys.select { |key| params[key].nil? }
          raise Error.new(message: "required keys are missing: #{missing_keys.join(', ')}") unless missing_keys.empty?
        end
      end
    end
  end
end
