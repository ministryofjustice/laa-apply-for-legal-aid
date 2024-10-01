require "rails_helper"

# rubocop:disable Rails/SaveBang
RSpec.describe Providers::Means::RegularIncomeForm do
  describe "#validate" do
    let(:legal_aid_application) { build_stubbed(:legal_aid_application, :with_applicant) }

    context "when neither a income type or none are selected" do
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
        }.merge(legal_aid_application:)

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
        expect(form.errors.messages[:transaction_type_ids]).to include("If you select 'My client does not get any of these payments', you cannot select any of the other options")
      end
    end

    context "when the correct attributes are provided" do
      it "is valid" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        params = {
          "transaction_type_ids" => ["", benefits.id, pension.id],
          "benefits_amount" => "250",
          "benefits_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).to be_valid
      end
    end
  end

  describe "#new" do
    context "when the application has regular transactions" do
      it "assigns attributes for the non-children credit transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        maintenance_in = create(:transaction_type, :maintenance_in)
        excluded_benefits = create(
          :transaction_type,
          :excluded_benefits,
          parent_id: maintenance_in.id,
        )
        _excluded_benefits_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: excluded_benefits,
        )
        _maintenance_in_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: maintenance_in,
        )
        _excluded_benefits_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: excluded_benefits,
          amount: 100,
          frequency: "weekly",
        )
        _maintenance_in_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: maintenance_in,
          amount: 250,
          frequency: "weekly",
          owner_id: legal_aid_application.applicant.id,
          owner_type: "Applicant",
        )

        form = described_class.new(legal_aid_application:)

        expect(form.transaction_type_ids).to contain_exactly(maintenance_in.id)
        expect(form.maintenance_in_amount).to eq(250)
        expect(form.maintenance_in_frequency).to eq("weekly")
      end
    end
  end

  describe "#save" do
    let!(:housing_benefit) { create(:transaction_type, :housing_benefit) }

    context "when the form is invalid" do
      it "returns false" do
        legal_aid_application = build_stubbed(:legal_aid_application)
        form = described_class.new(legal_aid_application:)

        result = form.save

        expect(result).to be false
      end

      it "does not update an application's transaction types" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        benefits = create(:transaction_type, :benefits)
        transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: benefits,
        )
        form = described_class.new(legal_aid_application:)

        form.save

        expect(legal_aid_application.legal_aid_application_transaction_types)
          .to contain_exactly(transaction_type)
      end

      it "does not update an application's regular transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
        )
        form = described_class.new(legal_aid_application:)

        form.save

        expect(legal_aid_application.regular_transactions)
          .to contain_exactly(regular_transaction)
      end

      it "does not update an application's cash transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        cash_transaction = create(:cash_transaction, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id)
        form = described_class.new(legal_aid_application:)

        form.save

        expect(legal_aid_application.cash_transactions)
          .to contain_exactly(cash_transaction)
      end
    end

    context "when none is selected" do
      let(:params) do
        {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
      end

      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
      let(:benefits) { create(:transaction_type, :benefits) }
      let(:pension) { create(:transaction_type, :pension) }
      let(:child_care) { create(:transaction_type, :child_care) }

      it "returns true" do
        form = described_class.new(params)
        result = form.save

        expect(result).to be true
      end

      it "updates `no_credit_transaction_types_selected` on the application" do
        legal_aid_application.update!(no_credit_transaction_types_selected: false)

        form = described_class.new(params)
        form.save

        expect(legal_aid_application.reload.no_credit_transaction_types_selected)
          .to be true
      end

      it "destroys any existing income transaction types" do
        _income_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: pension,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        outgoing_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: child_care,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )

        form = described_class.new(params)
        form.save

        expect(legal_aid_application.legal_aid_application_transaction_types)
          .to contain_exactly(outgoing_transaction_type)
      end

      it "does not destroy any existing housing benefit transaction types" do
        _income_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: pension,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        housing_benefit_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: housing_benefit,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )

        form = described_class.new(params)
        form.save

        expect(legal_aid_application.legal_aid_application_transaction_types)
          .to contain_exactly(housing_benefit_transaction_type)
      end

      it "does not destroy any existing benefit transaction types" do
        _income_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: pension,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        benefit_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: benefits,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )

        form = described_class.new(params)
        form.save

        expect(legal_aid_application.legal_aid_application_transaction_types)
          .to contain_exactly(benefit_transaction_type)
      end

      it "destroys any existing income regular transactions" do
        _income_regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: pension,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        outgoing_regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: child_care,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )

        form = described_class.new(params)
        form.save

        expect(legal_aid_application.regular_transactions)
          .to contain_exactly(outgoing_regular_transaction)
      end

      it "does not destroy any existing housing benefit regular transactions" do
        _income_regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: pension,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        housing_benefit_regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: housing_benefit,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )

        form = described_class.new(params)
        form.save

        expect(legal_aid_application.regular_transactions)
          .to contain_exactly(housing_benefit_regular_transaction)
      end

      it "destroys any existing cash transactions" do
        _income_cash_transaction = create(
          :cash_transaction,
          legal_aid_application:,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
          transaction_type: pension,
        )
        outgoing_cash_transaction = create(
          :cash_transaction,
          legal_aid_application:,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
          transaction_type: child_care,
        )

        form = described_class.new(params)
        form.save

        expect(legal_aid_application.cash_transactions)
          .to contain_exactly(outgoing_cash_transaction)
      end
    end

    context "when the correct attributes are provided" do
      it "returns true" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        benefits = create(:transaction_type, :benefits)
        params = {
          "transaction_type_ids" => ["", benefits.id],
          "benefits_amount" => "250.50",
          "benefits_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        result = form.save

        expect(result).to be true
      end

      it "updates `no_credit_transaction_types_selected` on the application" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          no_credit_transaction_types_selected: true,
        )
        benefits = create(:transaction_type, :benefits)
        params = {
          "transaction_type_ids" => ["", benefits.id],
          "benefits_amount" => "250.50",
          "benefits_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be false
      end

      it "updates the application's income transaction types" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        maintenance_in = create(:transaction_type, :maintenance_in)
        child_care = create(:transaction_type, :child_care)
        _old_income_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: maintenance_in,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        existing_income_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: benefits,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        outgoing_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: child_care,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        params = {
          "transaction_type_ids" => ["", benefits.id, pension.id],
          "benefits_amount" => "250.50",
          "benefits_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        new_transaction_type = LegalAidApplicationTransactionType.find_by!(
          legal_aid_application_id: legal_aid_application.id,
          transaction_type_id: pension.id,
        )
        transaction_types = legal_aid_application.legal_aid_application_transaction_types
        expect(transaction_types).to contain_exactly(
          existing_income_transaction_type,
          outgoing_transaction_type,
          new_transaction_type,
        )
      end

      it "updates the application's income regular transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        maintenance_in = create(:transaction_type, :maintenance_in)
        child_care = create(:transaction_type, :child_care)
        _old_income_regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: maintenance_in,
          owner_id: legal_aid_application.applicant.id,
          owner_type: "Applicant",
        )
        existing_income_regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: benefits,
          owner_id: legal_aid_application.applicant.id,
          owner_type: "Applicant",
        )
        outgoing_regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: child_care,
          owner_id: legal_aid_application.applicant.id,
          owner_type: "Applicant",
        )
        params = {
          "transaction_type_ids" => ["", benefits.id, pension.id],
          "benefits_amount" => "250.50",
          "benefits_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        new_regular_transaction = RegularTransaction.find_by!(
          legal_aid_application_id: legal_aid_application.id,
          transaction_type_id: pension.id,
        )
        regular_transactions = legal_aid_application.regular_transactions
        expect(regular_transactions).to contain_exactly(
          existing_income_regular_transaction,
          outgoing_regular_transaction,
          new_regular_transaction,
        )
      end

      it "updates the application's income cash transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        maintenance_in = create(:transaction_type, :maintenance_in)
        child_care = create(:transaction_type, :child_care)
        _old_income_cash_transaction = create(
          :cash_transaction,
          legal_aid_application:,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
          transaction_type: maintenance_in,
        )
        existing_income_cash_transaction = create(
          :cash_transaction,
          legal_aid_application:,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
          transaction_type: benefits,
        )
        outgoing_cash_transaction = create(
          :cash_transaction,
          legal_aid_application:,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
          transaction_type: child_care,
        )
        params = {
          "transaction_type_ids" => ["", benefits.id, pension.id],
          "benefits_amount" => "250.50",
          "benefits_frequency" => "weekly",
          "pension_amount" => "100",
          "pension_frequency" => "monthly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        cash_transactions = legal_aid_application.cash_transactions
        expect(cash_transactions).to contain_exactly(
          existing_income_cash_transaction,
          outgoing_cash_transaction,
        )
      end
    end
  end
end
# rubocop:enable Rails/SaveBang
