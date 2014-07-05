module WingMoney
  module SpecHelpers
    class ApiHelpers
      def online_payment_transaction_params(options = {})
        {
          :online_payment_transaction => {
            :amount => "1000",
            :wing_account_number => "884832",
            :wing_account_pin => "1234",
            :user_id => "wing-api-user-id",
            :password => "wing-api-secret",
            :biller_code => "12445"
          }.merge(options)
        }
      end
    end
  end
end
