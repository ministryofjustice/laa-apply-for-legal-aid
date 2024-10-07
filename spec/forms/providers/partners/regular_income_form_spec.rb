require "rails_helper"

RSpec.describe Providers::Partners::RegularIncomeForm do
  describe "#validate" do
    let(:legal_aid_application) { build_stubbed(:legal_aid_application, :with_applicant_and_partner) }

    context "when neither an outgoing type or none are selected" do
      it "is invalid" do
        params = {
          "transaction_type_ids" => [""],
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:transaction_type_ids, :blank)
      end
    end

    context "when at least one income type is selected, but an amount is missing" do
      it "is invalid" do
        maintenance_in = create(:transaction_type, :maintenance_in)
        pension = create(:transaction_type, :pension)
        params = {
          "transaction_type_ids" => ["", maintenance_in.id, pension.id],
          "maintenance_in_amount" => "",
          "maintenance_in_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:maintenance_in_amount, :not_a_number, value: "")
      end
    end

    context "when at least one income type is selected, but an invalid amount is given" do
      it "is invalid" do
        maintenance_in = create(:transaction_type, :maintenance_in)
        pension = create(:transaction_type, :pension)
        params = {
          "transaction_type_ids" => ["", maintenance_in.id, pension.id],
          "maintenance_in_amount" => "-1000",
          "maintenance_in_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:maintenance_in_amount, :greater_than, value: -1000, count: 0)
      end
    end

    context "when at least one income type is selected, but a frequency is missing" do
      it "is invalid" do
        maintenance_in = create(:transaction_type, :maintenance_in)
        pension = create(:transaction_type, :pension)
        params = {
          "transaction_type_ids" => ["", maintenance_in.id, pension.id],
          "maintenance_in_amount" => "250",
          "maintenance_in_frequency" => "",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:maintenance_in_frequency, :inclusion, value: "")
      end
    end

    context "when at least one income type is selected, but an invalid frequency is given" do
      it "is invalid" do
        maintenance_in = create(:transaction_type, :maintenance_in)
        pension = create(:transaction_type, :pension)
        params = {
          "transaction_type_ids" => ["", maintenance_in.id, pension.id],
          "maintenance_in_amount" => "250",
          "maintenance_in_frequency" => "invalid",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:maintenance_in_frequency, :inclusion, value: "invalid")
      end
    end

    context "when none is selected" do
      it "is valid" do
        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).to be_valid
      end
    end

    context "when none plus one income type is selected" do
      it "is invalid" do
        maintenance_in = create(:transaction_type, :maintenance_in)
        params = {
          "transaction_type_ids" => ["", "none", maintenance_in.id],
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:transaction_type_ids, :none_and_another_option_selected)
        expect(form.errors.messages[:transaction_type_ids]).to include("If you select 'The partner does not get any of these payments', you cannot select any of the other options")
      end
    end

    context "when the correct attributes are provided" do
      it "is valid" do
        legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner)
        maintenance_in = create(:transaction_type, :maintenance_in)
        pension = create(:transaction_type, :pension)
        params = {
          "transaction_type_ids" => ["", maintenance_in.id, pension.id],
          "maintenance_in_amount" => "250",
          "maintenance_in_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).to be_valid
      end
    end
  end
end
