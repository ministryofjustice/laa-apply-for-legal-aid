require "rails_helper"

RSpec.describe Providers::Means::CapitalDisregards::AddDetailsForm do
  subject(:form) { described_class.new(params.merge(model: capital_disregard)) }

  let(:application) { create(:legal_aid_application, :with_applicant, capital_disregards: [capital_disregard]) }
  let(:capital_disregard) { create(:capital_disregard, :discretionary) }

  let(:params) do
    {   payment_reason:,
        amount:,
        account_name:,
        date_received_3i:,
        date_received_2i:,
        date_received_1i: }
  end
  let(:payment_reason) { nil }
  let(:amount) { 123 }
  let(:account_name) { "Barclays" }
  let(:date_received) { Date.new(2023, 2, 1) }
  let(:date_received_3i) { date_received.day }
  let(:date_received_2i) { date_received.month }
  let(:date_received_1i) { date_received.year }

  describe "#save" do
    subject(:call_save) { form.save }

    before { call_save }

    it "is valid" do
      expect(form).to be_valid
    end

    it "updates the capital_disregard" do
      expect(application.capital_disregards.first)
        .to have_attributes(
          amount: 123,
          account_name: "Barclays",
          date_received: Date.new(2023, 2, 1),
        )
    end

    context "with humanized monetary value" do
      let(:amount) { "£1,244.55" }

      it "is valid" do
        expect(form).to be_valid
      end

      it "saves the monetary result" do
        expect(application.capital_disregards.first.amount).to eq(1_244.55)
      end
    end

    context "when amount is missing" do
      let(:amount) { nil }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "adds an error message" do
        error_messages = form.errors.messages.values.flatten
        expect(error_messages).to include("Enter a number for the amount received")
      end
    end

    context "when amount contains more than two decimals" do
      let(:amount) { 14.555 }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "adds an error message" do
        error_messages = form.errors.messages.values.flatten
        expect(error_messages).to include("Enter the amount received, like 1,000 or 20.30")
      end
    end

    context "when the account name is left blank" do
      let(:account_name) { "" }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "adds an error message" do
        error_messages = form.errors.messages.values.flatten
        expect(error_messages).to include("Enter which account the payment is in")
      end
    end

    context "when the date received is left blank" do
      let(:date_received) { Date.new }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "adds an error message" do
        error_messages = form.errors.messages.values.flatten
        expect(error_messages).to include("Enter a date in the correct format for when the payment is received")
      end
    end

    context "when the disregard is backdated benefits" do
      context "and it is mandatory" do
        let(:capital_disregard) { create(:capital_disregard, :mandatory) }

        context "and the date is within the last 2 years" do
          let(:date_received) { 2.years.ago }

          it "is valid" do
            expect(form).to be_valid
          end

          it "saves the date received" do
            expect(application.capital_disregards.first.date_received).to eq(Time.zone.today - 2.years)
          end
        end

        context "and the date is more than 2 years ago" do
          let(:date_received) { 3.years.ago }

          it "is invalid" do
            expect(form).not_to be_valid
          end

          it "adds an error message" do
            expect(form.errors[:date_received]).to include("Enter a date that is within the last 24 months")
          end
        end
      end

      context "and it is discretionary" do
        context "and the date is more than 2 years ago" do
          let(:date_received) { 3.years.ago }

          it "is valid" do
            expect(form).to be_valid
          end

          it "saves the date received" do
            expect(application.capital_disregards.first.date_received).to eq(Time.zone.today - 3.years)
          end
        end

        context "and the date is within the last 2 years" do
          let(:date_received) { 2.years.ago }

          it "is invalid" do
            expect(form).not_to be_valid
          end

          it "adds an error message" do
            expect(form.errors[:date_received]).to include("Enter a date that is over 24 months ago")
          end
        end
      end
    end

    context "when the payment reason is blank" do
      let(:capital_disregard) { create(:capital_disregard, name:) }
      let(:name) { "compensation_for_personal_harm" }
      let(:payment_reason) { "" }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "adds an error message" do
        error_messages = form.errors.messages.values.flatten
        expect(error_messages).to include("Enter what the payment is for")
      end
    end
  end

  describe "save_as_draft" do
    subject(:call_save_as_draft) { form.save_as_draft }

    before { call_save_as_draft }

    it "is valid" do
      expect(form).to be_valid
    end

    it "updates the capital_disregard" do
      expect(application.capital_disregards.first.amount).to eq 123
      expect(application.capital_disregards.first.account_name).to eq "Barclays"
      expect(application.discretionary_capital_disregards.first.date_received).to eq Date.new(2023, 2, 1)
    end

    context "when the disregard is backdated benefits" do
      context "and it is mandatory" do
        let(:capital_disregard) { create(:capital_disregard, :mandatory) }

        context "and the date is within the last 2 years" do
          let(:date_received) { 2.years.ago }

          it "is valid" do
            expect(form).to be_valid
          end

          it "saves the date received" do
            expect(application.capital_disregards.first.date_received).to eq(Time.zone.today - 2.years)
          end
        end

        context "and the date is more than 2 years ago" do
          let(:date_received) { 3.years.ago }

          it "is invalid" do
            expect(form).not_to be_valid
          end

          it "adds an error message" do
            expect(form.errors[:date_received]).to include("Enter a date that is within the last 24 months")
          end
        end
      end

      context "and it is discretionary" do
        context "and the date is more than 2 years ago" do
          let(:date_received) { 3.years.ago }

          it "is valid" do
            expect(form).to be_valid
          end

          it "saves the date received" do
            expect(application.capital_disregards.first.date_received).to eq(Time.zone.today - 3.years)
          end
        end

        context "and the date is within the last 2 years" do
          let(:date_received) { 2.years.ago }

          it "is invalid" do
            expect(form).not_to be_valid
          end

          it "adds an error message" do
            expect(form.errors[:date_received]).to include("Enter a date that is over 24 months ago")
          end
        end
      end
    end
  end
end
