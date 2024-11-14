require "rails_helper"

# rubocop:disable Rails/SaveBang
RSpec.describe Providers::Means::HousingBenefitForm do
  describe "#new" do
    context "when the applicant is receiving housing benefit" do
      it "assigns housing benefit attributes" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          applicant_in_receipt_of_housing_benefit: true,
        )
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
          amount: 500,
          frequency: "weekly",
          owner_id: legal_aid_application.applicant.id,
          owner_type: "Applicant",
        )
        params = { legal_aid_application: }

        form = described_class.new(params)

        expect(form).to have_attributes(
          applicant_in_receipt_of_housing_benefit: true,
          housing_benefit_amount: 500,
          housing_benefit_frequency: "weekly",
        )
      end
    end

    context "when the applicant is not receiving housing benefit" do
      it "assigns housing benefit attributes" do
        legal_aid_application = build_stubbed(
          :legal_aid_application,
          :with_applicant,
          applicant_in_receipt_of_housing_benefit: false,
        )
        params = { legal_aid_application: }

        form = described_class.new(params)

        expect(form).to have_attributes(
          applicant_in_receipt_of_housing_benefit: false,
          housing_benefit_amount: nil,
          housing_benefit_frequency: nil,
        )
      end
    end

    context "when the applicant has not answered the question" do
      it "does not assign housing benefit attributes" do
        legal_aid_application = build_stubbed(
          :legal_aid_application,
          :with_applicant,
          applicant_in_receipt_of_housing_benefit: nil,
        )
        params = { legal_aid_application: }

        form = described_class.new(params)

        expect(form).to have_attributes(
          applicant_in_receipt_of_housing_benefit: nil,
          housing_benefit_amount: nil,
          housing_benefit_frequency: nil,
        )
      end
    end
  end

  describe "#validate" do
    context "when no housing benefit option is selected" do
      it "is invalid" do
        legal_aid_application = build_stubbed(:legal_aid_application, :with_applicant)
        params = {
          "transaction_type_ids" => "",
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(:transaction_type_ids, :blank)
      end
    end

    context "when the applicant does not receive housing benefit" do
      it "is valid" do
        legal_aid_application = build_stubbed(:legal_aid_application, :with_applicant)
        params = {
          "transaction_type_ids" => "none",
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).to be_valid
      end
    end

    context "when the applicant receives housing benefit, but amount is blank" do
      it "is invalid" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        legal_aid_application = build_stubbed(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "weekly",
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(
          :housing_benefit_amount,
          :not_a_number,
          value: "",
        )
      end
    end

    context "when the applicant receives housing benefit, but amount is invalid" do
      it "is invalid" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        legal_aid_application = build_stubbed(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "-100",
          "housing_benefit_frequency" => "weekly",
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(
          :housing_benefit_amount,
          :greater_than,
          value: -100,
          count: 0,
        )
      end
    end

    context "when the applicant receives housing benefit, but frequency is blank" do
      it "is invalid" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        legal_aid_application = build_stubbed(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "100",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(
          :housing_benefit_frequency,
          :inclusion,
          value: "",
        )
      end
    end

    context "when the applicant receives housing benefit, but frequency is invalid" do
      it "is invalid" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        legal_aid_application = build_stubbed(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "100",
          "housing_benefit_frequency" => "invalid",
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).not_to be_valid
        expect(form.errors).to be_added(
          :housing_benefit_frequency,
          :inclusion,
          value: "invalid",
        )
      end
    end

    context "when housing benefit is true, and amount and frequency are valid" do
      it "is valid" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        legal_aid_application = build_stubbed(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "100",
          "housing_benefit_frequency" => "weekly",
          legal_aid_application:,
        }

        form = described_class.new(params)

        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    context "when the form is invalid" do
      it "returns false" do
        legal_aid_application = build_stubbed(:legal_aid_application, :with_applicant)
        params = {
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }
        form = described_class.new(params)

        result = form.save

        expect(result).to be false
      end

      it "does not update the applicant_in_receipt_of_housing_benefit attribute" do
        legal_aid_application = build_stubbed(
          :legal_aid_application,
          :with_applicant,
          applicant_in_receipt_of_housing_benefit: false,
        )
        params = {
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.applicant_in_receipt_of_housing_benefit)
          .to be false
      end

      it "does not update an application's transaction types" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.transaction_types).to be_empty
      end

      it "does not update an application's regular transactions" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.regular_transactions).to be_empty
      end
    end

    context "when housing benefit is false" do
      it "returns true" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        _transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => "none",
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }
        form = described_class.new(params)

        result = form.save

        expect(result).to be true
      end

      it "updates the applicant_in_receipt_of_housing_benefit attribute" do
        legal_aid_application = create(
          :legal_aid_application,
          applicant_in_receipt_of_housing_benefit: true,
        )
        _transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => "none",
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.applicant_in_receipt_of_housing_benefit)
          .to be false
      end

      it "destroys any existing housing benefit transaction types" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        _housing_benefit = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type:,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        params = {
          "transaction_type_ids" => "none",
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.transaction_types).to be_empty
      end

      it "destroys any existing housing benefit regular transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        _housing_benefit = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type:,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
        params = {
          "transaction_type_ids" => "none",
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.regular_transactions).to be_empty
      end
    end

    context "when housing benefit is true" do
      it "returns true" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "100",
          "housing_benefit_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        result = form.save

        expect(result).to be true
      end

      it "updates the applicant_in_receipt_of_housing_benefit attribute" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          applicant_in_receipt_of_housing_benefit: true,
        )
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "100",
          "housing_benefit_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.applicant_in_receipt_of_housing_benefit)
          .to be true
      end

      it "updates the application's transaction types" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "100",
          "housing_benefit_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        expect(legal_aid_application.transaction_types)
          .to contain_exactly(transaction_type)
      end

      it "updates the application's regular transactions" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "100",
          "housing_benefit_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)

        form.save

        regular_transactions = legal_aid_application.regular_transactions
        expect(regular_transactions.count).to eq 1
        expect(regular_transactions.first).to have_attributes(
          legal_aid_application:,
          transaction_type:,
          amount: 100,
          frequency: "weekly",
        )
      end

      it "cleans the housing benefit regular transactions amount of humanized characters" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        transaction_type = create(:transaction_type, :housing_benefit)
        params = {
          "transaction_type_ids" => transaction_type.id,
          "housing_benefit_amount" => "£1,543.66",
          "housing_benefit_frequency" => "weekly",
          legal_aid_application:,
        }
        form = described_class.new(params)
        form.save

        expect(legal_aid_application.regular_transactions.first).to have_attributes(amount: 1_543.66)
      end

      context "when a housing benefit regular transaction already exists" do
        it "does not create another legal aid application transaction type" do
          legal_aid_application = create(:legal_aid_application, :with_applicant)
          transaction_type = create(:transaction_type, :housing_benefit)
          legal_aid_application_transaction_type = create(
            :legal_aid_application_transaction_type,
            legal_aid_application:,
            owner_type: "Applicant",
            owner_id: legal_aid_application.applicant.id,
            transaction_type:,
          )
          _housing_benefit = create(
            :regular_transaction,
            legal_aid_application:,
            transaction_type:,
          )
          params = {
            "transaction_type_ids" => transaction_type.id,
            "housing_benefit_amount" => "200",
            "housing_benefit_frequency" => "monthly",
            legal_aid_application:,
          }
          form = described_class.new(params)

          form.save

          expect(legal_aid_application.legal_aid_application_transaction_types)
            .to contain_exactly(legal_aid_application_transaction_type)
        end

        it "updates the existing regular transaction" do
          legal_aid_application = create(:legal_aid_application, :with_applicant)
          transaction_type = create(:transaction_type, :housing_benefit)
          housing_benefit = create(
            :regular_transaction,
            legal_aid_application:,
            transaction_type:,
            amount: 100,
            frequency: "weekly",
            owner_id: legal_aid_application.applicant.id,
            owner_type: "Applicant",
          )
          params = {
            "transaction_type_ids" => transaction_type.id,
            "housing_benefit_amount" => "200",
            "housing_benefit_frequency" => "monthly",
            legal_aid_application:,
          }
          form = described_class.new(params)

          form.save

          expect(legal_aid_application.regular_transactions)
            .to contain_exactly(housing_benefit)
          expect(housing_benefit.reload).to have_attributes(
            legal_aid_application:,
            transaction_type:,
            amount: 200,
            frequency: "monthly",
          )
        end
      end
    end
  end
end
# rubocop:enable Rails/SaveBang
