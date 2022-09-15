require "rails_helper"

# rubocop:disable Rails/SaveBang
RSpec.describe Providers::Means::RegularIncomeForm do
  describe "validations" do
    context "when neither a income type or none are selected" do
      it "is invalid" do
        params = { "income_types" => [""] }

        form = described_class.new(params)

        expect(form).to be_invalid
        expect(form.errors).to be_added(:income_types, :blank)
      end
    end

    context "when at least one income type is selected, but an amount is missing" do
      it "is invalid" do
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        params = {
          "income_types" => ["", benefits.name, pension.name],
          "benefits_amount" => "",
          "benefits_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }

        form = described_class.new(params)

        expect(form).to be_invalid
        expect(form.errors).to be_added(:benefits_amount, :not_a_number, value: "")
      end
    end

    context "when at least one income type is selected, but an invalid amount is given" do
      it "is invalid" do
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        params = {
          "income_types" => ["", benefits.name, pension.name],
          "benefits_amount" => "-1000",
          "benefits_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }

        form = described_class.new(params)

        expect(form).to be_invalid
        expect(form.errors).to be_added(:benefits_amount, :greater_than, value: -1000, count: 0)
      end
    end

    context "when at least one income type is selected, but a frequency is missing" do
      it "is invalid" do
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        params = {
          "income_types" => ["", benefits.name, pension.name],
          "benefits_amount" => "250",
          "benefits_frequency" => "",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }

        form = described_class.new(params)

        expect(form).to be_invalid
        expect(form.errors).to be_added(:benefits_frequency, :inclusion, value: "")
      end
    end

    context "when at least one income type is selected, but an invalid frequency is given" do
      it "is invalid" do
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        params = {
          "income_types" => ["", benefits.name, pension.name],
          "benefits_amount" => "250",
          "benefits_frequency" => "invalid",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }

        form = described_class.new(params)

        expect(form).to be_invalid
        expect(form.errors).to be_added(:benefits_frequency, :inclusion, value: "invalid")
      end
    end

    context "when none is selected" do
      it "is valid" do
        params = { "income_types" => ["", "none"] }

        form = described_class.new(params)

        expect(form).to be_valid
      end
    end

    context "when the correct attributes are provided" do
      it "is valid" do
        legal_aid_application = create(:legal_aid_application)
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        params = {
          "income_types" => ["", benefits.name, pension.name],
          "benefits_amount" => "250",
          "benefits_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
          "maintenance_in_amount" => "100",
          "maintenance_in_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    context "when the form is invalid" do
      it "returns false" do
        form = described_class.new

        result = form.save

        expect(result).to be false
      end

      it "does not update an application's regular transactions" do
        legal_aid_application = create(:legal_aid_application)
        regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
        )
        form = described_class.new(legal_aid_application:)

        form.save

        expect(legal_aid_application.regular_transactions)
          .to contain_exactly(regular_transaction)
      end
    end

    context "when none is selected" do
      it "returns true" do
        legal_aid_application = create(:legal_aid_application)
        params = {
          "income_types" => ["", "none"],
          "legal_aid_application" => legal_aid_application,
        }
        form = described_class.new(params)

        result = form.save

        expect(result).to be true
      end

      it "updates `no_credit_transaction_types_selected` on the application" do
        legal_aid_application = create(
          :legal_aid_application,
          no_credit_transaction_types_selected: false,
        )
        params = {
          "income_types" => ["", "none"],
          "legal_aid_application" => legal_aid_application,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.reload.no_credit_transaction_types_selected)
          .to be true
      end

      it "does not create any regular transactions" do
        legal_aid_application = create(:legal_aid_application)
        params = {
          "income_types" => ["", "none"],
          "legal_aid_application" => legal_aid_application,
        }
        form = described_class.new(params)

        form.save

        expect(RegularTransaction.count).to eq 0
      end

      it "destroys any existing regular income payments" do
        legal_aid_application = create(:legal_aid_application)
        benefits = create(:transaction_type, :benefits)
        child_care = create(:transaction_type, :child_care)
        _regular_income_payment = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: benefits,
        )
        regular_outgoing_payment = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: child_care,
        )
        params = {
          "income_types" => ["", "none"],
          "legal_aid_application" => legal_aid_application,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.regular_transactions)
          .to contain_exactly(regular_outgoing_payment)
      end
    end

    context "when the correct attributes are provided" do
      it "returns true" do
        legal_aid_application = create(:legal_aid_application)
        benefits = create(:transaction_type, :benefits)
        params = {
          "income_types" => ["", benefits.name],
          "benefits_amount" => "250.50",
          "benefits_frequency" => "weekly",
          "legal_aid_application" => legal_aid_application,
        }
        form = described_class.new(params)

        result = form.save

        expect(result).to be true
      end

      it "updates `no_credit_transaction_types_selected` on the application" do
        legal_aid_application = create(
          :legal_aid_application,
          no_credit_transaction_types_selected: true,
        )
        benefits = create(:transaction_type, :benefits)
        params = {
          "income_types" => ["", benefits.name],
          "benefits_amount" => "250.50",
          "benefits_frequency" => "weekly",
          "legal_aid_application" => legal_aid_application,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be false
      end

      it "updates an application's regular transactions" do
        legal_aid_application = create(:legal_aid_application)
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        maintenance_in = create(:transaction_type, :maintenance_in)
        _maintenance_in_payment = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: maintenance_in,
        )
        params = {
          "income_types" => ["", benefits.name, pension.name],
          "benefits_amount" => "250.50",
          "benefits_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
          "maintenance_in_amount" => "100",
          "maintenance_in_frequency" => "monthly",
          "legal_aid_application" => legal_aid_application,
        }
        form = described_class.new(params)

        form.save

        regular_transactions = legal_aid_application.regular_transactions
        expect(regular_transactions.count).to eq 2
        expect(regular_transactions.pluck(:transaction_type_id, :amount, :frequency))
          .to contain_exactly([benefits.id, 250.50, "weekly"], [pension.id, 100, "monthly"])
      end
    end
  end
end
# rubocop:enable Rails/SaveBang
