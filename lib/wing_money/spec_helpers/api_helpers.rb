module WingMoney
  module SpecHelpers
    class ApiHelpers

      def authentication_headers(key)
        {'HTTP_AUTHORIZATION' => bearer_authentication(key)}
      end

      def online_payment_transaction_params(options = {})
        build_request_params(:wing_transaction_online_payment, options) do |merge_params|
          wing_transaction_params.merge(
            :biller_code => "1244"
          ).merge(merge_params)
        end
      end

      def wing_to_wing_transaction_params(options = {})
        build_request_params(:wing_transaction_wing_to_wing, options) do |merge_params|
          wing_transaction_params.merge(
            :wing_destination_account_number => "884834",
            :wing_destination_usd_account_number => "884834",
            :wing_destination_khr_account_number => "1615",
            :khr_usd_buy_rate => "41.5",
            :khr_usd_sell_rate => "40",
          ).merge(merge_params)
        end
      end

      def wei_luy_transaction_params(options = {})
        build_request_params(:wing_transaction_wei_luy, options) do |merge_params|
          wing_transaction_params.merge(
            :recipient_mobile => "85512239137"
          ).merge(merge_params)
        end
      end

      private

      def bearer_authentication(key)
        "Bearer #{key}"
      end

      def build_request_params(root_key, options = {}, &block)
        merge_params = options.dup
        root = merge_params.delete(:root)
        root = true unless root == false
        request_params = yield(merge_params)
        root ? {root_key => request_params} : request_params
      end

      def wing_transaction_params
        {
          :amount => "1000",
          :currency => "usd",
          :wing_account_number => "884832",
          :wing_account_pin => "1234",
          :user_id => "wing-api-user-id",
          :password => "wing-api-secret",
        }
      end
    end
  end
end
