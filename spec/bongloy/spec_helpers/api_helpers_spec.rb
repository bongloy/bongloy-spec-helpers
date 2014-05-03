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
    end
  end
end
