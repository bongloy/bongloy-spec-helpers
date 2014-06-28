require 'spec_helper'
require "./lib/bongloy/spec_helpers/api_helpers"

module Bongloy
  module SpecHelpers
    describe ApiHelpers do
      describe "#sample_customer_id(sequence = nil)" do
        it "should return a bongloy sample customer id" do
          subject.sample_customer_id.should =~ /^cus_/
        end

        context "passing a sequence" do
          it "should put the sequence at the end of the customer id" do
            subject.sample_customer_id(1).should =~ /1$/
          end
        end
      end

      describe "#sample_token_id(sequence = nil)" do
        it "should return a bongloy sample token id" do
          subject.sample_token_id.should =~ /^tok_/
        end

        context "passing a sequence" do
          it "should put the sequence at the end of the token id" do
            subject.sample_token_id(1).should =~ /1$/
          end
        end
      end

      describe "#sample_card_id(sequence = nil)" do
        it "should return a bongloy sample card id" do
          subject.sample_card_id.should =~ /^card_/
        end

        context "passing a sequence" do
          it "should put the sequence at the end of the card id" do
            subject.sample_card_id(1).should =~ /1$/
          end
        end
      end

      describe "#sample_charge_id(sequence = nil)" do
        it "should return a bongloy sample charge id" do
          subject.sample_charge_id.should =~ /^ch_/
        end

        context "passing a sequence" do
          it "should put the sequence at the end of the charge id" do
            subject.sample_charge_id(1).should =~ /1$/
          end
        end
      end

      describe "#sample_balance_transaction_id(sequence = nil)" do
        it "should return a bongloy sample balance transaction id" do
          subject.sample_balance_transaction_id.should =~ /^txn_/
        end

        context "passing a sequence" do
          it "should put the sequence at the end of the balance transaction id" do
            subject.sample_balance_transaction_id(1).should =~ /1$/
          end
        end
      end

      describe "#sample_credit_card_numbers" do
        it "should return a hash sample credit card numbers" do
          subject.sample_credit_card_numbers.should have_key(:visa)
          subject.sample_credit_card_numbers.should have_key(:mastercard)
        end
      end

      describe "#authentication_headers(key)" do
        it "should return HTTP headers for Bearer authentication" do
          subject.authentication_headers("foo")["HTTP_AUTHORIZATION"].should == "Bearer foo"
        end
      end

      describe "#asserted_authentication_headers(key)" do
        it "should return the asserted HTTP headers for Bearer authentication" do
          subject.asserted_authentication_headers("foo")["Authorization"].should == "Bearer foo"
        end
      end

      describe "#credit_card_token_params(options = {})" do
        it "should return a set of token params suitable for creating credit card tokens" do
          subject.credit_card_token_params.should have_key(:card)
        end
      end

      describe "#sample_credit_card(options = {})" do
        it "should return a sample response for a credit card" do
          subject.sample_credit_card.keys.should =~ [
            "id", "object", "last4", "type", "fingerprint", "customer", "country",
            "created", "address_line1_check", "address_zip_check", "cvc_check",
            "exp_month", "exp_year", "name", "address_line1", "address_line2", "address_city",
            "address_state", "address_zip", "address_country"
          ]
        end
      end

      describe "#sample_customer(options = {})" do
        it "should return a sample response for a customer" do
          subject.sample_customer.keys.should =~ [
            "id", "object", "created", "livemode", "description", "email", "default_card"
          ]
        end
      end

      describe "#sample_charge(options = {})" do
        it "should return a sample response for a charge" do
          subject.sample_charge.keys.should =~ [
            "id", "object", "created", "livemode", "description",
            "amount", "currency", "card", "captured", "balance_transaction", "customer"
          ]
        end
      end

      describe "#sample_balance_transaction(options = {})" do
        it "should return a sample response for a balance transaction" do
          subject.sample_balance_transaction.keys.should =~ [
            "id", "object", "created", "amount", "currency",
            "type", "source", "available_on", "status"
          ]
        end
      end

      describe "#update_customer_http_method" do
        context "stripe is the endpoint" do
          subject { described_class.new(:api_endpoint => ENV["STRIPE_API_ENDPOINT"]) }

          it "should return :post" do
            subject.update_customer_http_method.should == :post
          end
        end

        context "bongloy is the endpoint" do
          it "should return :put" do
            subject.update_customer_http_method.should == :put
          end
        end
      end

      describe "#create_token_headers" do
        context "passing {'X-CUSTOM-HEADER' => 'foo'}" do
          it "should return the custom headers" do
            subject.create_token_headers({'X-CUSTOM-HEADER' => 'foo'}).should == {'X-CUSTOM-HEADER' => 'foo'}
          end
        end

        context "passing no args" do
          it "should return authorization headers" do
            subject.create_token_headers.should == {"Authorization" => "Bearer "}
          end
        end
      end

      describe "#stripe_mode?" do
        context "the endpoint is stripe" do
          subject { described_class.new(:api_endpoint => ENV["STRIPE_API_ENDPOINT"]) }
          it { should be_stripe_mode }
        end

        context "the endpoint is not stripe" do
          it { should_not be_stripe_mode }
        end
      end

      describe "#charge_params(options = {})" do
        let(:result) { subject.charge_params(charge_params_options) }

        context "passing no options" do
          let(:charge_params_options) { { } }

          it "should return no customer or card params" do
            result.should have_key("amount")
            result.should have_key("currency")
          end

          context "passing other options" do
            let(:charge_params_options) { { "amount" => "4000", "currency" => "khr" } }

            it "should override the default params" do
              result["amount"].should == "4000"
              result["currency"].should == "khr"
            end
          end
        end
      end
    end
  end
end
