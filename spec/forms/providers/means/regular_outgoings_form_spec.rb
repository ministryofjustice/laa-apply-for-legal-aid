require "rails_helper"

# rubocop:disable Rails/SaveBang
RSpec.describe Providers::Means::RegularOutgoingsForm do
  describe "#validate" do
    let(:legal_aid_application) { build_stubbed(:legal_aid_application, :with_applicant) }

    context "when neither a outgoing type or none are selected" do
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

    context "when at least one outgoing type is selected, but an amount is missing" do
      it "is invalid" do
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        child_care = create(:transaction_type, :child_care)
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id, child_care.id],
          "rent_or_mortgage_amount" => "",
          "rent_or_mortgage_frequency" => "weekly",
          "child_care_amount" => "100",
          "child_care_frequency" => "monthly",
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:rent_or_mortgage_amount, :not_a_number, value: "")
      end
    end

    context "when at least one outgoing type is selected, but an invalid amount is given" do
      it "is invalid" do
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        child_care = create(:transaction_type, :child_care)
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id, child_care.id],
          "rent_or_mortgage_amount" => "-1000",
          "rent_or_mortgage_frequency" => "weekly",
          "child_care_amount" => "100",
          "child_care_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:rent_or_mortgage_amount, :greater_than, value: -1000, count: 0)
      end
    end

    context "when at least one outgoing type is selected, but a frequency is missing" do
      it "is invalid" do
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        child_care = create(:transaction_type, :child_care)
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id, child_care.id],
          "rent_or_mortgage_amount" => "250",
          "rent_or_mortgage_frequency" => "",
          "child_care_amount" => "100",
          "child_care_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:rent_or_mortgage_frequency, :inclusion, value: "")
      end
    end

    context "when at least one outgoing type is selected, but an invalid frequency is given" do
      it "is invalid" do
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        child_care = create(:transaction_type, :child_care)
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id, child_care.id],
          "rent_or_mortgage_amount" => "250",
          "rent_or_mortgage_frequency" => "invalid",
          "child_care_amount" => "100",
          "child_care_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:rent_or_mortgage_frequency, :inclusion, value: "invalid")
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

    context "when none plus one outgoings type is selected" do
      it "is invalid" do
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        params = {
          "transaction_type_ids" => ["", "none", rent_or_mortgage.id],
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:transaction_type_ids, :none_and_another_option_selected)
        expect(form.errors.messages[:transaction_type_ids]).to include("If you select 'My client makes none of these payments', you cannot select any of the other options")
      end
    end

    context "when the correct attributes are provided" do
      it "is valid" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        child_care = create(:transaction_type, :child_care)
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id, child_care.id],
          "rent_or_mortgage_amount" => "250",
          "rent_or_mortgage_frequency" => "weekly",
          "child_care_amount" => "100",
          "child_care_frequency" => "monthly",
          "maintenance_out_amount" => "100",
          "maintenance_out_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)

        expect(form).to be_valid
      end
    end
  end

  describe "#new" do
    context "when the application has regular transactions" do
      it "assigns attributes for the non-children debit transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        maintenance_out = create(:transaction_type, :maintenance_out)
        child = create(
          :transaction_type,
          name: "child_transaction_type",
          operation: "debit",
          parent_id: maintenance_out.id,
        )
        _child_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: child,
        )
        _maintenance_out_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: maintenance_out,
        )
        _child_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: child,
          amount: 100,
          frequency: "weekly",
        )
        _maintenance_out_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: maintenance_out,
          amount: 250,
          frequency: "weekly",
          owner_id: legal_aid_application.applicant.id,
          owner_type: "Applicant",
        )

        form = described_class.new(legal_aid_application:)

        expect(form.transaction_type_ids).to contain_exactly(maintenance_out.id)
        expect(form.maintenance_out_amount).to eq(250)
        expect(form.maintenance_out_frequency).to eq("weekly")
      end
    end
  end

  describe "#save" do
    context "when the form is invalid" do
      it "returns false" do
        legal_aid_application = build_stubbed(:legal_aid_application)
        form = described_class.new(legal_aid_application:)

        result = form.save

        expect(result).to be false
      end

      it "does not update an application's transaction types" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: rent_or_mortgage,
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

      it "does not update an application's housing benefit transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        legal_aid_application_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type:,
        )
        housing_benefit = create(
          :regular_transaction,
          :housing_benefit,
          legal_aid_application:,
        )
        form = described_class.new(legal_aid_application:)

        form.save

        expect(legal_aid_application.legal_aid_application_transaction_types)
          .to contain_exactly(legal_aid_application_transaction_type)
        expect(legal_aid_application.regular_transactions)
          .to contain_exactly(housing_benefit)
      end

      it "does not update the application" do
        legal_aid_application = create(
          :legal_aid_application,
          no_debit_transaction_types_selected: false,
          applicant_in_receipt_of_housing_benefit: true,
        )
        form = described_class.new(legal_aid_application:)

        form.save

        expect(legal_aid_application.reload).to have_attributes(
          no_debit_transaction_types_selected: false,
          applicant_in_receipt_of_housing_benefit: true,
        )
      end
    end

    context "when none is selected" do
      it "returns true" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
        form = described_class.new(params)

        result = form.save

        expect(result).to be true
      end

      it "updates the application" do
        legal_aid_application = create(
          :legal_aid_application,
          no_debit_transaction_types_selected: false,
          applicant_in_receipt_of_housing_benefit: true,
        )
        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.reload).to have_attributes(
          no_debit_transaction_types_selected: true,
          applicant_in_receipt_of_housing_benefit: nil,
        )
      end

      it "does not create any regular transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(RegularTransaction.count).to eq 0
      end

      it "destroys any existing regular outgoing transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        benefits = create(:transaction_type, :benefits)
        child_care = create(:transaction_type, :child_care)
        regular_income_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: benefits,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        _regular_outgoing_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: child_care,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.regular_transactions)
          .to contain_exactly(regular_income_transaction)
      end

      it "destroys any existing housing benefit transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        _legal_aid_application_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type:,
        )
        _housing_benefit = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type:,
        )
        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.legal_aid_application_transaction_types)
          .to be_empty
        expect(legal_aid_application.regular_transactions).to be_empty
      end

      it "updates application as not applicant_in_receipt_of_housing_benefit" do
        legal_aid_application = create(:legal_aid_application, applicant_in_receipt_of_housing_benefit: true)

        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
        form = described_class.new(params)

        expect { form.save }.to change(legal_aid_application, :applicant_in_receipt_of_housing_benefit).from(true).to(nil)
      end
    end

    context "when the correct attributes are provided" do
      it "returns true" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id],
          "rent_or_mortgage_amount" => "250.50",
          "rent_or_mortgage_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        result = form.save

        expect(result).to be true
      end

      it "updates `no_debit_transaction_types_selected` on the application" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          no_debit_transaction_types_selected: true,
        )
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id],
          "rent_or_mortgage_amount" => "250.50",
          "rent_or_mortgage_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.reload.no_debit_transaction_types_selected).to be false
      end

      it "updates an application's regular transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        child_care = create(:transaction_type, :child_care)
        maintenance_out = create(:transaction_type, :maintenance_out)
        _maintenance_out_payment = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: maintenance_out,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id, child_care.id],
          "rent_or_mortgage_amount" => "250.50",
          "rent_or_mortgage_frequency" => "weekly",
          "child_care_amount" => "100",
          "child_care_frequency" => "monthly",
          "maintenance_out_amount" => "100",
          "maintenance_out_frequency" => "monthly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        regular_transactions = legal_aid_application.regular_transactions
        expect(regular_transactions.count).to eq 2
        expect(regular_transactions.pluck(:transaction_type_id, :amount, :frequency))
          .to contain_exactly([rent_or_mortgage.id, 250.50, "weekly"], [child_care.id, 100, "monthly"])
      end

      it "cleans the regular transaction amount of humanized characters" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id],
          "rent_or_mortgage_amount" => "£2,333.55",
          "rent_or_mortgage_frequency" => "monthly",
        }.merge(legal_aid_application:)

        form = described_class.new(params)
        form.save

        expect(legal_aid_application.regular_transactions.first).to have_attributes(amount: 2_333.55)
      end

      it "destroys any existing housing benefit transactions if housing " \
         "payments are not selected" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        child_care = create(:transaction_type, :child_care)
        transaction_type = create(:transaction_type, :housing_benefit)
        legal_aid_application_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type:,
        )
        housing_benefit = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type:,
        )
        params = {
          "transaction_type_ids" => ["", child_care.id],
          "child_care_amount" => "100",
          "child_care_frequency" => "monthly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.legal_aid_application_transaction_types)
          .not_to include(legal_aid_application_transaction_type)
        expect(legal_aid_application.regular_transactions)
          .not_to include(housing_benefit)
      end

      it "does not destroy housing benefit transactions if housing payments " \
         "are selected" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        transaction_type = create(:transaction_type, :housing_benefit)
        legal_aid_application_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type:,
        )
        housing_benefit = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type:,
        )
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id],
          "rent_or_mortgage_amount" => "250.50",
          "rent_or_mortgage_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.legal_aid_application_transaction_types)
          .to include(legal_aid_application_transaction_type)
        expect(legal_aid_application.regular_transactions)
          .to include(housing_benefit)
      end

      it "updates applicant_in_receipt_of_housing_benefit if housing payments" \
         "are not selected" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          applicant_in_receipt_of_housing_benefit: false,
        )
        child_care = create(:transaction_type, :child_care)
        params = {
          "transaction_type_ids" => ["", child_care.id],
          "child_care_amount" => "100",
          "child_care_frequency" => "monthly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.reload).to have_attributes(
          applicant_in_receipt_of_housing_benefit: nil,
        )
      end

      it "does not update `applicant_in_receipt_of_housing_benefit if housing" \
         "payments are selected" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          applicant_in_receipt_of_housing_benefit: false,
        )
        rent_or_mortgage = create(:transaction_type, :rent_or_mortgage)
        params = {
          "transaction_type_ids" => ["", rent_or_mortgage.id],
          "rent_or_mortgage_amount" => "250.50",
          "rent_or_mortgage_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.reload).to have_attributes(
          applicant_in_receipt_of_housing_benefit: false,
        )
      end
    end
  end
end
# rubocop:enable Rails/SaveBang
