require 'spec_helper'
require "./lib/bongloy/spec_helpers/api_helpers"

module Bongloy
  module SpecHelpers
    describe ApiHelpers do
      describe "#generate_uuid" do
        it { expect(subject.generate_uuid).not_to eq(subject.generate_uuid) }
      end

      describe "#sample_credit_card_numbers" do
        it { expect(subject.sample_credit_card_numbers).to have_key(:visa) }
        it { expect(subject.sample_credit_card_numbers).to have_key(:mastercard) }
        it { expect(subject.sample_credit_card_numbers).to have_key(:wing) }
      end

      describe "#authentication_headers(key)" do
        it { expect(subject.authentication_headers("foo")["HTTP_AUTHORIZATION"]).to eq("Bearer foo") }
      end

      describe "#asserted_authentication_headers(key)" do
        it { expect(subject.asserted_authentication_headers("foo")["Authorization"]).to eq("Bearer foo") }
      end

      describe "#card_params(options = {})" do
        let(:card_params) { subject.card_params }
        it { expect(card_params).to have_key("exp_month") }
        it { expect(card_params).to have_key("exp_year") }
        it { expect(card_params).to have_key("name") }
      end

      describe "#credit_card_token_params(options = {})" do
        it { expect(subject.credit_card_token_params).to have_key(:card) }
      end

      describe "#wing_card_token_params(options = {})" do
        it { expect(subject.wing_card_token_params).to have_key(:card) }
      end

      describe "#sample_credit_card(options = {})" do
        it do
          expect(subject.sample_credit_card.keys).to match_array([
            "id", "object", "last4", "brand", "fingerprint", "customer", "country",
            "created", "address_line1_check", "address_zip_check", "cvc_check",
            "exp_month", "exp_year", "name", "address_line1", "address_line2", "address_city",
            "address_state", "address_zip", "address_country"
          ])
        end
      end

      describe "#sample_wing_card(options = {})" do
        it do
          expect(subject.sample_wing_card.keys).to match_array(["address_city", "address_country",
            "address_line1", "address_line2", "address_state", "address_zip",
            "country", "created", "customer", "exp_month", "exp_year",
            "fingerprint", "id", "name", "object", "last4", "brand"
          ])
        end
      end

      describe "#sample_customer(options = {})" do
        it do
          expect(subject.sample_customer.keys).to match_array([
            "id", "object", "created", "livemode", "description", "email", "default_source"
          ])
        end
      end

      describe "#sample_charge(options = {})" do
        it do
          expect(subject.sample_charge.keys).to match_array([
            "id", "object", "created", "livemode", "description",
            "amount", "currency", "source", "captured", "balance_transaction", "customer"
          ])
        end
      end

      describe "#sample_balance_transaction(options = {})" do
        it do
          expect(subject.sample_balance_transaction.keys).to match_array([
            "id", "object", "created", "amount", "currency",
            "type", "source", "available_on", "status"
          ])
        end
      end

      describe "#update_customer_http_method" do
        context "stripe is the endpoint" do
          subject { described_class.new(:api_endpoint => ENV["STRIPE_API_ENDPOINT"]) }
          it { expect(subject.update_customer_http_method).to eq(:post) }
        end

        context "bongloy is the endpoint" do
          it { expect(subject.update_customer_http_method).to eq(:put) }
        end
      end

      describe "#create_token_headers" do
        context "passing {'X-CUSTOM-HEADER' => 'foo'}" do
          it { expect(subject.create_token_headers({'X-CUSTOM-HEADER' => 'foo'})).to eq({'X-CUSTOM-HEADER' => 'foo'}) }
        end

        context "passing no args" do
          it { expect(subject.create_token_headers).to eq({"Authorization" => "Bearer "}) }
        end
      end

      describe "#stripe_mode?" do
        context "the endpoint is stripe" do
          subject { described_class.new(:api_endpoint => ENV["STRIPE_API_ENDPOINT"]) }
          it { is_expected.to be_stripe_mode }
        end

        context "the endpoint is not stripe" do
          it { is_expected.not_to be_stripe_mode }
        end
      end

      describe "#charge_params(options = {})" do
        let(:result) { subject.charge_params(charge_params_options) }

        context "passing no options" do
          let(:charge_params_options) { { } }
          it { expect(result).to have_key("amount") }
          it { expect(result).to have_key("currency") }

          context "passing other options" do
            let(:charge_params_options) { { "amount" => "4000", "currency" => "khr" } }

            it { expect(result["amount"]).to eq("4000") }
            it { expect(result["currency"]).to eq("khr") }
          end
        end
      end
    end
  end
end
