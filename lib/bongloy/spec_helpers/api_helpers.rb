module Bongloy
  module SpecHelpers
    class ApiHelpers
      BONGLOY_API_ENDPOINT = "https://api.bongloy.com/v1"

      attr_accessor :api_endpoint

      def initialize(options = {})
        self.api_endpoint = options[:api_endpoint] || ENV["BONGLOY_API_ENDPOINT"] || BONGLOY_API_ENDPOINT
      end

      def sample_customer_id(sequence = nil)
        "cus_b4139166aa8e4e62f4d72c08a3acaa7713ff97eab78b3b75001661b8d7b99797#{sequence}"
      end

      def sample_token_id(sequence = nil)
        "tok_50415d300fd45f72475abc75392708dedcd7500c7a98a7a62e34411f4c8a6640#{sequence}"
      end

      def sample_card_id(sequence = nil)
        "card_60415d300fd45f72475abc75392708dedcd7500c7a98a7a62e34411f4c8a6640#{sequence}"
      end

      def authentication_headers(key)
        {'HTTP_AUTHORIZATION' => "Bearer #{key}"}
      end

      def sample_email
        "someone@example.com"
      end

      def sample_credit_card_numbers
        {
          :visa => "4242424242424242",
          :mastercard => "5555555555554444"
        }
      end

      def credit_card_token_params(options = {})
        {
          :card => {
            "number" => sample_credit_card_numbers[:visa],
          }.merge(
            sample_credit_card_params[:exp_date]
          ).merge(
            sample_credit_card_params[:cvc]
          ).merge(
            sample_credit_card_params[:optional]
          ).merge(options)
        }
      end

      def stub_get_customer(options = {})
        WebMock.stub_request(:get, customer_url(options)).to_return(sample_customer_response(options))
      end

      def stub_check_publishable_key(options = {})
        WebMock.stub_request(
          :post, tokens_url(options)
        ).to_return(sample_token_response(options))
      end

      def create_token_headers(headers = nil)
        headers || {'Authorization' => "Bearer #{ENV['CHECKOUT_ACCESS_TOKEN']}"}
      end

      def stub_create_token(options = {})
        response_options = options.dup
        customer_id = response_options[:customer_id] || sample_customer_id
        # stub with headers to avoid conflicts with #stub_check_publishable_key
        headers = create_token_headers(response_options.delete(:headers))
        WebMock.stub_request(
          :post, tokens_url(response_options)
        ).with(:headers => headers).to_return(sample_token_response(response_options))
      end

      def stub_create_customer(options = {})
        WebMock.stub_request(
          :post, customers_url(options)
        ).to_return(sample_customer_response(options))
      end

      def update_customer_http_method
        stripe_mode? ? :post : :put
      end

      def stub_update_customer(options = {})
        WebMock.stub_request(
          update_customer_http_method, customer_url(options)
        ).to_return(sample_customer_response(options))
      end

      def stub_get_token(options = {})
        WebMock.stub_request(:get, token_url(options)).to_return(sample_token_response(options))
      end

      def sample_credit_card(options = {})
        card_id = options[:card_id] || sample_card_id
        {
          "id" => card_id,
          "object" => "card",
          "last4" => "4242",
          "type" => "Visa",
          "fingerprint" => "Xt5EWLLDS7FJjR1c",
          "customer" => nil,
          "country" => "US",
          "created" => 1396430418,
          "address_line1_check" => nil,
          "address_zip_check" => nil,
          "cvc_check" => nil
        }.merge(sample_credit_card_params[:exp_date]).merge(sample_credit_card_params[:optional])
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
          "card" => sample_credit_card(options)
        }.merge("email" => sample_email).merge(options.slice(:email).stringify_keys)
      end

      def sample_customer(options = {})
        customer_id = options[:customer_id] || sample_customer_id
        card_id = options[:card_id] || sample_card_id

        {
          "id" => customer_id,
          "object" => "customer",
          "created" => 1396430334,
          "livemode" => false,
          "description" => nil,
          "email" => nil,
          "default_card" => sample_credit_card(options)
        }
      end

      def customers_url(options = {})
        "#{api_endpoint}/customers"
      end

      def customer_url(options = {})
        customer_id = options[:customer_id] || sample_customer_id
        /^#{api_endpoint}\/customers\/#{customer_id}.*/
      end

      def tokens_url(options = {})
        "#{api_endpoint}/tokens"
      end

      def token_url(options = {})
        if token_id = options[:token_id]
          "#{api_endpoint}/tokens/#{token_id}"
        else
          /^#{api_endpoint}\/tokens\/\w+/
        end
      end

      def stripe_mode?
        api_endpoint =~ /api.stripe.com/
      end

      private

      def sample_customer_response(options = {})
        {
          :body => sample_customer(options).to_json,
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

      def sample_credit_card_params
        {
          :exp_date => {
            "exp_month" => 12,
            "exp_year" => Time.now.year + 1
          },
          :cvc => {
            "cvc" => "123"
          },
          :optional => {
            "name" => "John Citizen",
            "address_line1" => "cc Address Line 1",
            "address_line2" => "cc Address Line 2",
            "address_city" => "Melbourne",
            "address_state" => "Victoria",
            "address_zip" => "3001",
            "address_country" => "Australia"
          }
        }
      end
    end
  end
end
