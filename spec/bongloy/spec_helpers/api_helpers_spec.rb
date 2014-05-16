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
    end
  end
end
