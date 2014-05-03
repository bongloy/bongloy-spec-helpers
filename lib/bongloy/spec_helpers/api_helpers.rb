module Bongloy
  module SpecHelpers
    class ApiHelpers
      def sample_customer_id(sequence = nil)
        "cus_3mJ8eGjetRskOq#{sequence}"
      end

      def sample_email
        "someone@example.com"
      end

      def stub_get_customer(options = {})
        WebMock.stub_request(:get, customer_url(options)).to_return(sample_customer_response(options))
      end

      def stub_check_publishable_key(options = {})
        WebMock.stub_request(
          :post, tokens_url(options)
        ).to_return(sample_token_response(options))
      end

      def stub_create_token(options = {})
        customer_id = options[:customer_id] || sample_customer_id
        # stub with headers to avoid conflicts with #stub_check_publishable_key
        WebMock.stub_request(
          :post, tokens_url(options)
        ).with(:headers => {'Authorization' => "Bearer #{ENV['CHECKOUT_ACCESS_TOKEN']}"}).to_return(sample_token_response(options))
      end

      def stub_create_customer(options = {})
        WebMock.stub_request(
          :post, customers_url(options)
        ).to_return(sample_customer_response(options))
      end

      def stub_update_customer(options = {})
        stub_get_customer(options)
        WebMock.stub_request(
          :post, customer_url(options)
        ).to_return(sample_customer_response(options))
      end

      def stub_get_token(options = {})
        WebMock.stub_request(:get, token_url(options)).to_return(sample_token_response(options))
      end

      def sample_card(options = {})
        card_id = options[:card_id] || sample_card_id
        {
          "id" => sample_card_id,
          "object" => "card",
          "last4" => "4242",
          "type" => "Visa",
          "exp_month" => 8,
          "exp_year" => 2015,
          "fingerprint" => "Xt5EWLLDS7FJjR1c",
          "customer" => nil,
          "country" => "US",
          "name" => nil,
          "address_line1" => nil,
          "address_line2" => nil,
          "address_city" => nil,
          "address_state" => nil,
          "address_zip" => nil,
          "address_country" => nil
        }
      end

      def sample_token(options = {})
        token_id = options[:token_id] || sample_token_id
        {
          "id" => token_id,
          "livemode" => false,
          "created" => 1396430418,
          "used" => false,
          "object" => "token",
          "type" => "card",
          "card" => sample_card(options)
        }.merge("email" => sample_email).merge(options.slice(:email).stringify_keys)
      end

      def sample_token_id
        "tok_103mJ925nfuGqgVOwJPSrhYd"
      end

      def customers_url(options = {})
        uri = URI.parse(api_endpoint)
        uri.path = "/v1/customers"
        uri.to_s
      end

      def customer_url(options = {})
        customer_id = options[:customer_id] || sample_customer_id
        /^#{api_endpoint}\/v1\/customers\/#{customer_id}.*/
      end

      def tokens_url(options = {})
        uri = URI.parse(api_endpoint)
        uri.path = "/v1/tokens"
        uri.to_s
      end

      def token_url(options = {})
        if token_id = options[:token_id]
          uri = URI.parse(api_endpoint)
          uri.path = "/v1/tokens/#{token_id}"
          uri.to_s
        else
          /^#{api_endpoint}\/v1\/tokens\/\w+/
        end
      end

      private

      def sample_customer_response(options = {})
        customer_id = options[:customer_id] || sample_customer_id
        card_id = options[:card_id] || sample_card_id

        body = {
          "id" => customer_id,
          "object" => "customer",
          "created" => 1396430334,
          "livemode" => false,
          "description" => nil,
          "email" => nil,
          "delinquent" => false,
          "metadata" => {},
          "subscriptions" => {
            "object" => "list",
            "total_count" => 0,
            "has_more" => false,
            "url" => "/v1/customers/#{customer_id}/subscriptions",
            "data" => []
          },
          "discount" => nil,
          "account_balance" => 0,
          "currency" => nil,
          "cards" => {
            "object" => "list",
            "total_count" => 1,
            "has_more" => false,
            "url" => "/v1/customers/#{customer_id}/cards",
            "data" => [sample_card(options)]
          },
          "default_card" => sample_card(options)
        }
        {
          :body => body.to_json,
          :status => 200,
          :headers => {'Content-Type' => "application/json;charset=utf-8"}
        }
      end

      def sample_token_response(options = {})
        token = sample_token(options)
        token_id = token["id"]

        if options[:not_found]
          token_error("No such token: #{token_id}", "param" => "token")
        elsif options[:missing_required_params]
          token_error("You must supply either a card, customer, or bank account to create a token.")
        elsif options[:no_key]
          token_error("You did not provide an API key. You need to provide your API key in the Authorization header, using Bearer auth (e.g. 'Authorization: Bearer YOUR_SECRET_KEY'). See https://stripe.com/docs/api#authentication for details, or we can help at https://support.stripe.com/.", :status => 401)
        elsif options[:incorrect_key]
          token_error("Invalid API Key provided: pk_test_***********************", :status => 401)
        else
          {:body => token.to_json, :status => 200}
        end
      end

      def token_error(message, options = {})
        token_error_options = options.dup
        status = token_error_options.delete(:status) || 400
        {
          :body => {
            "error" => {
              "type" => "invalid_request_error",
              "message" => message,
            }.merge(options)
          }.to_json,
          :status => status
        }
      end

      def sample_card_id
        "card_103mIH25nfuGqgVO7zJIVtvD"
      end

      # change me later
      def api_endpoint
        "https://api.stripe.com"
      end
    end
  end
end
