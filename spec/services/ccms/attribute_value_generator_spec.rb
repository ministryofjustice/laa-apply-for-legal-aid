require "rails_helper"

module CCMS
  RSpec.describe AttributeValueGenerator, :ccms do
    let(:submission) { create(:submission) }
    let(:value_generator) { described_class.new(submission) }

    describe "#method_missing" do
      context "with a standardly_named_method" do
        describe "bank account" do
          let(:my_account) { instance_double BankAccount }
          let(:options) { { bank_acct: my_account } }
          let(:bank_account_name) { "MY ACCOUNT" }

          it "calls #name on the options[:bank_acct]" do
            expect(my_account).to receive(:name).and_return(bank_account_name)
            account_name = value_generator.bank_account_name(options)
            expect(account_name).to eq bank_account_name
          end
        end

        describe "vehicle" do
          let(:my_vehicle) { instance_double Vehicle }
          let(:options) { { vehicle: my_vehicle } }
          let(:my_estimated_value) { 1000.00 }

          it "calls the #regno method on options[:vehicle]" do
            expect(my_vehicle).to receive(:estimated_value).and_return(my_estimated_value)
            estimated_value = value_generator.vehicle_estimated_value(options)
            expect(estimated_value).to eq my_estimated_value
          end
        end

        describe "proceeding" do
          let(:my_proceeding) { instance_double Proceeding }
          let(:options) { { proceeding: my_proceeding } }
          let(:my_name) { "Non-mol" }

          it "calls the #name method on options[:proceeding]" do
            expect(my_proceeding).to receive(:name).and_return(my_name)
            name = value_generator.proceeding_name(options)
            expect(name).to eq my_name
          end
        end
      end

      context "with a non-standardly-named method" do
        it "raises NoMethodError error" do
          expect {
            value_generator.no_such_method
          }.to raise_error NoMethodError
        end
      end
    end

    describe "#respond_to?" do
      context "with standardly_named methods" do
        let(:my_account) { instance_double BankAccount, name: "MY ACCOUNT" }
        let(:options) { { bank_acct: my_account } }

        context "and a valid method on delegated object" do
          it "returns true" do
            expect(value_generator.respond_to?(:bank_account_name)).to be true
          end
        end
      end

      context "with non-standardly-named methods" do
        describe "other existing method" do
          it "returns true" do
            expect(value_generator.respond_to?(:bank_account_holders)).to be true
          end
        end

        describe "non-existing method" do
          it "returns false" do
            expect(value_generator.respond_to?(:non_existent_method)).to be false
          end
        end
      end
    end
  end
end
