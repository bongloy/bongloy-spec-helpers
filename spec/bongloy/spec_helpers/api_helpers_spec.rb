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
    end
  end
end
