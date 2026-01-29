require "rails_helper"

RSpec.describe Applicant do
  describe "when creating an applicant record" do
    subject(:created_applicant) { described_class.create }

    it "leaves the has_partner field as nil" do
      expect(created_applicant.has_partner).to be_nil
    end
  end

  describe "on validation" do
    subject(:applicant) { described_class.new }

    before do
      applicant.first_name = "John"
      applicant.last_name = "Doe"
      applicant.date_of_birth = Date.new(1988, 0o2, 0o1)
      applicant.national_insurance_number = "AB123456D"
    end

    it "is valid with all valid attributes" do
      expect(applicant).to be_valid
    end

    context "with an existing applicant" do
      let!(:existing_applicant) { create(:applicant) }

      it "allows another applicant to be created with same email" do
        expect { create(:applicant, email: existing_applicant.email) }.to change(described_class, :count).by(1)
      end
    end
  end

  describe ".json_for_hmrc" do
    subject(:json_for_hmrc) { described_class.new.json_for_hmrc }

    it "returns the expected values" do
      expect(json_for_hmrc.keys).to match_array %i[first_name last_name nino dob]
    end

    it "does not include model values we are not concerned with" do
      expect(json_for_hmrc.keys).not_to include %i[id status created_at updated_at email employed]
    end
  end

  # Main purpose: to ensure relationships to other object set so that destroying applicant destroys all objects
  # that then become redundant.
  describe ".destroy_all" do
    subject(:destroy_all) { described_class.destroy_all }

    let!(:applicant) { create(:applicant, :with_address) }
    # Creating a bank transaction creates an applicant and the objects between it and the transaction
    let!(:bank_transaction) { create(:bank_transaction) }
    let(:bank_provider) { bank_transaction.bank_account.bank_provider }

    before do
      create(:bank_error, applicant:)
      create(:bank_account_holder, bank_provider:)
      create(:legal_aid_application, applicant:)
    end

    it "removes everything it needs to" do
      expect(described_class.count).not_to be_zero
      expect(Address.count).not_to be_zero
      expect(BankProvider.count).not_to be_zero
      expect(BankTransaction.count).not_to be_zero
      expect(LegalAidApplication.count).not_to be_zero
      expect(BankAccountHolder.count).not_to be_zero
      expect(BankError.count).not_to be_zero
      destroy_all
      expect(described_class.count).to be_zero
      expect(Address.count).to be_zero
      expect(BankProvider.count).to be_zero
      expect(BankTransaction.count).to be_zero
      expect(LegalAidApplication.count).to be_zero
      expect(BankAccountHolder.count).to be_zero
      expect(BankError.count).to be_zero
    end
  end

  describe "#encrypted_true_layer_token" do
    subject(:encrypted_true_layer_token) { applicant.encrypted_true_layer_token }

    let(:applicant) do
      build(
        :applicant,
        encrypted_true_layer_token: {
          token: "test-token", expires_at: 1.day.ago
        },
      )
    end

    before { freeze_time }

    it "returns the token" do
      expect(encrypted_true_layer_token).to match(
        "token" => "test-token",
        "expires_at" => 1.day.ago.iso8601(3),
      )
    end
  end

  describe "#true_layer_token" do
    subject(:true_layer_token) { applicant.true_layer_token }

    let(:applicant) { build(:applicant, encrypted_true_layer_token:) }

    context "when the encrypted token is nil" do
      let(:encrypted_true_layer_token) { nil }

      it { is_expected.to be_nil }
    end

    context "when the encrypted token does not contain a token" do
      let(:encrypted_true_layer_token) { { expires_at: 1.year.ago } }

      it { is_expected.to be_nil }
    end

    context "when the encrypted token contains a token" do
      let(:encrypted_true_layer_token) { { token: "test-token" } }

      it { is_expected.to eq("test-token") }
    end
  end

  describe "#surname_at_birth" do
    subject(:surname_at_birth) { legal_aid_application.applicant.surname_at_birth }

    let(:legal_aid_application) do
      build(:legal_aid_application, :with_transaction_period, applicant:)
    end

    context "when a last_name_at_birth is set" do
      let(:applicant) { build(:applicant, last_name: "current", last_name_at_birth: "different") }

      it { is_expected.to eql "different" }
    end

    context "when a last_name_at_birth is not set" do
      let(:applicant) { build(:applicant, last_name: "current", last_name_at_birth: nil) }

      it { is_expected.to eql "current" }
    end
  end

  describe "#age" do
    subject(:age) { legal_aid_application.applicant.age }

    let(:applicant) { build(:applicant, date_of_birth: 48.years.ago) }

    let(:legal_aid_application) do
      build(:legal_aid_application, :with_transaction_period, applicant:)
    end

    it "returns the calculated age of the applicant" do
      expect(age).to be 48
    end

    context "when non-means-tested application and applicant under 18" do
      before do
        applicant.age_for_means_test_purposes = 17
      end

      it "returns age stored in age_for_means_test_purposes" do
        expect(age).to be 17
      end
    end

    context "when sca application" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_sca_proceedings, applicant:) }

      before do
        applicant.age_for_means_test_purposes = 48
      end

      it "returns age stored in age_for_means_test_purposes" do
        expect(age).to be 48
      end
    end

    context "when the application has non-means-tested plf proceedings" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_public_law_family_non_means_tested_proceeding, applicant:) }

      before do
        applicant.age_for_means_test_purposes = 49
      end

      it "returns age stored in age_for_means_test_purposes" do
        expect(age).to be 49
      end
    end
  end

  describe "#under_18?" do
    subject(:under_18?) { applicant.under_18? }

    context "when 18 for means test purposes" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: 18) }

      it { is_expected.to be false }
    end

    context "when under 18 for means test purposes" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: 17) }

      it { is_expected.to be true }
    end

    context "when nil for means test purposes" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: nil) }

      it { is_expected.to be false }
    end
  end

  describe "#over_17?" do
    subject(:over_17?) { applicant.over_17? }

    context "when 17 for means test purposes" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: 17) }

      it { is_expected.to be true }
    end

    context "when under 17 for means test purposes" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: 16) }

      it { is_expected.to be false }
    end

    context "when nil for means test purposes" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: nil) }

      it { is_expected.to be false }
    end
  end

  describe "#child?" do
    subject(:child?) { legal_aid_application.applicant.child? }

    let(:legal_aid_application) do
      build(:legal_aid_application, :with_transaction_period, applicant:)
    end

    context "when exactly 16" do
      let(:applicant) { build(:applicant, date_of_birth: 16.years.ago) }

      it { is_expected.to be false }
    end

    context "when 1 day before 16" do
      let(:applicant) { build(:applicant, date_of_birth: 16.years.ago + 1.day) }

      it { is_expected.to be true }
    end
  end

  describe "#no_means_test_required?" do
    subject { applicant.no_means_test_required? }

    let(:applicant) { build(:applicant) }

    context "with age_for_means_test_purposes of 17" do
      before { applicant.age_for_means_test_purposes = 17 }

      it { is_expected.to be true }
    end

    context "with age_for_means_test_purposes of 18" do
      before { applicant.age_for_means_test_purposes = 18 }

      it { is_expected.to be false }
    end

    context "with age_for_means_test_purposes of nil" do
      before { applicant.age_for_means_test_purposes = nil }

      it { is_expected.to be false }
    end
  end

  describe "#receives_financial_support?" do
    subject { legal_aid_application.applicant.receives_financial_support? }

    let(:applicant) { create(:applicant) }
    let(:legal_aid_application) { create(:legal_aid_application, applicant:, transaction_types: [benefits]) }
    let(:bank_provider) { create(:bank_provider, applicant:) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:friends_or_family) { create(:transaction_type, :credit, :friends_or_family) }
    let(:benefits) { create(:transaction_type, :credit, name: "benefits") }

    before { create(:bank_transaction, :credit, transaction_type: benefits, bank_account:) }

    context "when they receive friends and family income" do
      before { create(:bank_transaction, :credit, transaction_type: friends_or_family, bank_account:) }

      it { is_expected.to be true }
    end

    context "when they do not receive friends and family income" do
      it { is_expected.to be false }
    end
  end

  context "with income checks" do
    let(:applicant) { create(:applicant) }
    let(:benefits) { create(:transaction_type, :credit, name: "benefits") }
    let(:transaction_array) { [benefits] }
    let(:legal_aid_application) { create(:legal_aid_application, applicant:, transaction_types: transaction_array) }
    let!(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }

    describe "#receives_maintenance?" do
      subject { legal_aid_application.applicant.receives_maintenance? }

      context "when they receive maintenance" do
        context "with cfe version 3" do
          before { create(:cfe_v3_result, :with_maintenance_received, submission: cfe_submission) }

          it { is_expected.to be true }
        end

        context "with cfe version 4 result" do
          before { create(:cfe_v4_result, :with_maintenance_received, submission: cfe_submission) }

          it { is_expected.to be true }
        end
      end

      context "when they do not receive maintenance" do
        context "with cfe version 3" do
          before { create(:cfe_v3_result, submission: cfe_submission) }

          it { is_expected.to be false }
        end

        context "with cfe version 4 result" do
          before { create(:cfe_v4_result, submission: cfe_submission) }

          it { is_expected.to be false }
        end
      end
    end

    describe "#maintenance_per_month" do
      subject { legal_aid_application.applicant.maintenance_per_month }

      context "when they receive maintenance" do
        context "with cfe version 3" do
          before { create(:cfe_v3_result, :with_maintenance_received, submission: cfe_submission) }

          it { is_expected.to eq "150.00" }
        end

        context "with cfe version 4 result" do
          before { create(:cfe_v4_result, :with_maintenance_received, submission: cfe_submission) }

          it { is_expected.to eq "150.00" }
        end
      end

      context "when they do not receive maintenance" do
        context "with cfe version 3" do
          before { create(:cfe_v3_result, submission: cfe_submission) }

          it { is_expected.to eq "0.00" }
        end

        context "with cfe version 4 result" do
          before { create(:cfe_v4_result, submission: cfe_submission) }

          it { is_expected.to eq "0.00" }
        end
      end
    end
  end

  describe "#mortgage_per_month" do
    subject { legal_aid_application.applicant.mortgage_per_month }

    let(:legal_aid_application) { create(:legal_aid_application, :with_everything) }
    let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }

    context "with cfe version 3 result" do
      context "when they pay a mortgage" do
        before { create(:cfe_v3_result, submission: cfe_submission) }

        it { is_expected.to eq "125.00" }
      end

      context "when they do not pay a mortgage" do
        before { create(:cfe_v3_result, :with_no_mortgage_costs, submission: cfe_submission) }

        it { is_expected.to eq "0.00" }
      end
    end

    context "with cfe version 4 result" do
      context "when they pay a mortgage" do
        before { create(:cfe_v4_result, :with_mortgage_costs, submission: cfe_submission) }

        it { is_expected.to eq "120.00" }
      end

      context "when they do not pay a mortgage" do
        before { create(:cfe_v4_result, submission: cfe_submission) }

        it { is_expected.to eq "0.00" }
      end
    end
  end

  describe "#valid_cfe_result_version?" do
    let(:applicant) { create(:applicant) }

    context "with CFE version 3 result" do
      it "returns true" do
        create(:legal_aid_application, :with_cfe_v3_result, applicant:)
        expect(applicant.valid_cfe_result_version?).to be true
      end
    end

    context "with CFE version 4 result" do
      it "returns true" do
        create(:legal_aid_application, :with_cfe_v4_result, applicant:)
        expect(applicant.valid_cfe_result_version?).to be true
      end
    end

    context "with CFE version 5 result" do
      it "returns true" do
        create(:legal_aid_application, :with_cfe_v5_result, applicant:)
        expect(applicant.valid_cfe_result_version?).to be true
      end
    end

    context "with CFE version out of scope result" do
      let(:cfe_version_5_result) { instance_double CFE::V5::Result }

      it "returns false" do
        create(:legal_aid_application, applicant:)
        allow(applicant).to receive(:cfe_result_type).and_return(cfe_version_5_result)
        expect(applicant.valid_cfe_result_version?).to be false
      end
    end
  end

  describe "employment status" do
    describe "#not_employed?" do
      context "when not employed" do
        it "returns true" do
          applicant = build(:applicant, :not_employed)
          expect(applicant.not_employed?).to be true
        end
      end

      context "when armed forces" do
        it "returns false" do
          applicant = build(:applicant, :armed_forces)
          expect(applicant.not_employed?).to be false
        end
      end

      context "when self employed" do
        it "returns false" do
          applicant = build(:applicant, :self_employed)
          expect(applicant.not_employed?).to be false
        end
      end

      context "when employed and self employed" do
        it "returns false" do
          applicant = build(:applicant, :employed, :self_employed)
          expect(applicant.not_employed?).to be false
        end
      end

      context "when all three" do
        it "returns false" do
          applicant = build(:applicant, :employed, :self_employed, :armed_forces)
          expect(applicant.not_employed?).to be false
        end
      end
    end
  end

  describe "#employment_status" do
    context "when employed" do
      it "returns Employed" do
        applicant = build(:applicant, :employed)
        expect(applicant.employment_status).to eq "Employed"
      end
    end

    context "when not employed" do
      it "returns Not employed" do
        applicant = build(:applicant, :not_employed)
        expect(applicant.employment_status).to eq "Not employed"
      end
    end
  end

  describe "home_address_for_ccms" do
    subject(:home_address_for_ccms) { applicant.home_address_for_ccms }

    let(:applicant) { create(:applicant, no_fixed_residence:, addresses:) }
    let(:correspondence_address) { create(:address, address_line_one: "109 Correspondence Avenue") }
    let(:home_address) { create(:address, :as_home_address, address_line_one: "27 Home Street") }
    let(:addresses) { [correspondence_address, home_address] }

    context "when applicant.no_fixed_residence is true" do
      let(:no_fixed_residence) { true }

      it { is_expected.to be_nil }
    end

    context "when applicant.no_fixed_residence is false" do
      let(:no_fixed_residence) { false }

      context "and a home record has been created" do
        it { expect(home_address_for_ccms.address_line_one).to eq "27 Home Street" }
      end

      context "and a home record has not been created" do
        let(:addresses) { [correspondence_address] }

        it { expect(home_address_for_ccms.address_line_one).to eq "109 Correspondence Avenue" }
      end
    end

    context "when the application was created before the home address feature flag was added" do
      let(:no_fixed_residence) { nil }

      context "and a home record has been created" do # this should not be possible, but we should return it if it exists
        it { expect(home_address_for_ccms.address_line_one).to eq "27 Home Street" }
      end

      context "and a home record has not been created" do
        let(:addresses) { [correspondence_address] }

        it { expect(home_address_for_ccms.address_line_one).to eq "109 Correspondence Avenue" }
      end
    end
  end

  describe "correspondence_address_for_ccms" do
    subject(:correspondence_address_for_ccms) { applicant.correspondence_address_for_ccms }

    let(:applicant) { create(:applicant, same_correspondence_and_home_address:, addresses:) }
    let(:correspondence_address) { create(:address, address_line_one: "109 Correspondence Avenue") }
    let(:home_address) { create(:address, :as_home_address, address_line_one: "27 Home Street") }
    let(:addresses) { [correspondence_address, home_address] }

    context "when the provider has recorded same_correspondence_and_home_address as true" do
      let(:same_correspondence_and_home_address) { true }

      it { expect(correspondence_address_for_ccms.address_line_one).to eq "27 Home Street" }
    end

    context "when the provider has recorded same_correspondence_and_home_address as false" do
      let(:same_correspondence_and_home_address) { false }

      it { expect(correspondence_address_for_ccms.address_line_one).to eq "109 Correspondence Avenue" }
    end

    context "when the application was created before the home address feature flag was added" do
      let(:same_correspondence_and_home_address) { nil }

      it { expect(correspondence_address_for_ccms.address_line_one).to eq "109 Correspondence Avenue" }
    end
  end
end
