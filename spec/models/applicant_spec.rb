require "rails_helper"

RSpec.describe Applicant do
  describe "on validation" do
    subject { described_class.new }

    before do
      subject.first_name = "John"
      subject.last_name = "Doe"
      subject.date_of_birth = Date.new(1988, 0o2, 0o1)
      subject.national_insurance_number = "AB123456D"
    end

    it "is valid with all valid attributes" do
      expect(subject).to be_valid
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
      expect(json_for_hmrc.keys).not_to include %i[id status created_at updated_at email employed true_layer_secure_data_id]
    end
  end

  # Main purpose: to ensure relationships to other object set so that destroying applicant destroys all objects
  # that then become redundant.
  describe ".destroy_all" do
    subject { described_class.destroy_all }

    let!(:applicant) { create(:applicant, :with_address) }
    let!(:legal_aid_application) { create(:legal_aid_application, applicant:) }
    # Creating a bank transaction creates an applicant and the objects between it and the transaction
    let!(:bank_transaction) { create(:bank_transaction) }
    let(:bank_provider) { bank_transaction.bank_account.bank_provider }
    let!(:bank_account_holder) { create(:bank_account_holder, bank_provider:) }
    let!(:bank_error) { create(:bank_error, applicant:) }

    it "removes everything it needs to" do
      expect(described_class.count).not_to be_zero
      expect(Address.count).not_to be_zero
      expect(BankProvider.count).not_to be_zero
      expect(BankTransaction.count).not_to be_zero
      expect(LegalAidApplication.count).not_to be_zero
      expect(BankAccountHolder.count).not_to be_zero
      expect(BankError.count).not_to be_zero
      subject
      expect(described_class.count).to be_zero
      expect(Address.count).to be_zero
      expect(BankProvider.count).to be_zero
      expect(BankTransaction.count).to be_zero
      expect(LegalAidApplication.count).to be_zero
      expect(BankAccountHolder.count).to be_zero
      expect(BankError.count).to be_zero
    end
  end

  describe "#store_true_layer_token" do
    let(:applicant) { build(:applicant, encrypted_true_layer_token: nil) }

    before { freeze_time }

    it "saves the token and expiry time" do
      applicant.store_true_layer_token(token: "test-token", expires: 1.year.ago)

      expiry_time_in_json_format = 1.year.ago.iso8601(3)
      expect(applicant.encrypted_true_layer_token).to match(
        "token" => "test-token",
        "expires_at" => expiry_time_in_json_format,
      )
    end
  end

  describe "#true_layer_token" do
    subject(:true_layer_token) { applicant.true_layer_token }

    let(:applicant) do
      create(
        :applicant,
        encrypted_true_layer_token:,
        true_layer_secure_data_id: secure_data_id,
      )
    end

    context "when there is encrypted data" do
      let(:encrypted_true_layer_token) { { token: "encrypted-token" } }
      let(:secure_data_id) { nil }

      it "returns the token" do
        expect(true_layer_token).to eq("encrypted-token")
      end
    end

    context "when there is only SecureData" do
      let(:encrypted_true_layer_token) { nil }
      let(:secure_data_id) { SecureData.create_and_store!(token: "secure-token") }

      it "returns the token" do
        expect(true_layer_token).to eq("secure-token")
      end
    end
  end

  describe "#true_layer_token_expires_at" do
    subject(:true_layer_token_expires_at) { applicant.true_layer_token_expires_at }

    let(:applicant) do
      create(
        :applicant,
        encrypted_true_layer_token:,
        true_layer_secure_data_id: secure_data_id,
      )
    end

    before { freeze_time }

    context "when there is encrypted data" do
      let(:encrypted_true_layer_token) { { expires_at: 1.year.ago } }
      let(:secure_data_id) { nil }

      it "returns the expiry time" do
        expect(true_layer_token_expires_at).to eq(1.year.ago)
      end
    end

    context "when there is only SecureData" do
      let(:encrypted_true_layer_token) { nil }
      let(:secure_data_id) { SecureData.create_and_store!(expires: 1.day.ago) }

      it "returns the expiry time" do
        expect(true_layer_token_expires_at).to eq(1.day.ago)
      end
    end
  end

  context "with True Layer Token" do
    subject { applicant.store_true_layer_token token:, expires: token_expires_at }

    let(:token) { SecureRandom.uuid }
    # Note - JSON time doesn't include micro seconds so need to round to second to get consistent result
    let(:token_expires_at) { 10.minutes.from_now.round(0) }
    let(:data) { { token:, expires: token_expires_at } }
    let(:applicant) { create(:applicant) }

    it "stores the data securely" do
      expect { subject }.to change(SecureData, :count).by(1)
    end

    it "associates the applicant with the secure data" do
      subject
      expect(applicant.true_layer_secure_data_id).to eq(SecureData.last.id)
    end

    describe "#true_layer_token" do
      it "returns the original token" do
        subject
        expect(applicant.true_layer_token).to eq(token)
      end
    end

    describe "#true_layer_token_expires_at" do
      it "returns the original expiry time" do
        subject
        expect(applicant.true_layer_token_expires_at).to eq(token_expires_at)
      end
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

    context "when MTR phase one enabled and applicant under 18" do
      before do
        allow(Setting).to receive(:means_test_review_phase_one?).and_return(true)
        applicant.age_for_means_test_purposes = 17
      end

      it "returns age stored in age_for_means_test_purposes" do
        expect(age).to be 17
      end
    end

    context "when MTR phase one disabled and under 16" do
      before do
        allow(Setting).to receive(:means_test_review_phase_one?).and_return(false)
      end

      it "returns age stored in age_for_means_test_purposes" do
        allow(applicant).to receive(:age_for_means_test_purposes).and_return(15)
        expect(age).to be 15
      end
    end

    context "when MTR phase one disabled and 16 or over" do
      before do
        allow(Setting).to receive(:means_test_review_phase_one?).and_return(false)
      end

      it "returns age calculated by AgeCalculator" do
        allow(AgeCalculator).to receive(:call).and_return(45)
        expect(age).to be 45
      end
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

    context "when means_test_review_phase_one? is enabled" do
      before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(true) }

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

    context "when means_test_review_phase_one? is disabled" do
      before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(false) }

      context "with age_for_means_test_purposes of 17" do
        before { applicant.age_for_means_test_purposes = 17 }

        it { is_expected.to be false }
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
  end

  describe "#under_16_blocked?" do
    subject { applicant.under_16_blocked? }

    let(:applicant) { build(:applicant) }

    context "when means_test_review_phase_one? is enabled" do
      before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(true) }

      context "with age_for_means_test_purposes of 15" do
        before { applicant.age_for_means_test_purposes = 15 }

        it { is_expected.to be false }
      end

      context "with age_for_means_test_purposes of 16" do
        before { applicant.age_for_means_test_purposes = 16 }

        it { is_expected.to be false }
      end

      context "with age_for_means_test_purposes of nil" do
        before { applicant.age_for_means_test_purposes = nil }

        it { is_expected.to be false }
      end
    end

    context "when means_test_review_phase_one? is disabled" do
      before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(false) }

      context "with age_for_means_test_purposes of 15" do
        before { applicant.age_for_means_test_purposes = 15 }

        it { is_expected.to be true }
      end

      context "with age_for_means_test_purposes of 16" do
        before { applicant.age_for_means_test_purposes = 16 }

        it { is_expected.to be false }
      end

      context "with age_for_means_test_purposes of nil" do
        before { applicant.age_for_means_test_purposes = nil }

        it { is_expected.to be false }
      end
    end
  end

  describe "#receives_financial_support?" do
    subject { legal_aid_application.applicant.receives_financial_support? }

    let(:applicant) { create(:applicant) }
    let(:bank_provider) { create(:bank_provider, applicant:) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:friends_or_family) { create(:transaction_type, :credit, :friends_or_family) }
    let(:benefits) { create(:transaction_type, :credit, name: "benefits") }
    let!(:benefits_bank_transaction) { create(:bank_transaction, :credit, transaction_type: benefits, bank_account:) }
    let(:legal_aid_application) { create(:legal_aid_application, applicant:, transaction_types: [benefits]) }

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
          let!(:cfe_result) { create(:cfe_v3_result, :with_maintenance_received, submission: cfe_submission) }

          it { is_expected.to be true }
        end

        context "with cfe version 4 result" do
          let!(:cfe_result) { create(:cfe_v4_result, :with_maintenance_received, submission: cfe_submission) }

          it { is_expected.to be true }
        end
      end

      context "when they do not receive maintenance" do
        context "with cfe version 3" do
          let!(:cfe_result) { create(:cfe_v3_result, submission: cfe_submission) }

          it { is_expected.to be false }
        end

        context "with cfe version 4 result" do
          let!(:cfe_result) { create(:cfe_v4_result, submission: cfe_submission) }

          it { is_expected.to be false }
        end
      end
    end

    describe "#maintenance_per_month" do
      subject { legal_aid_application.applicant.maintenance_per_month }

      context "when they receive maintenance" do
        context "with cfe version 3" do
          let!(:cfe_result) { create(:cfe_v3_result, :with_maintenance_received, submission: cfe_submission) }

          it { is_expected.to eq "150.00" }
        end

        context "with cfe version 4 result" do
          let!(:cfe_result) { create(:cfe_v4_result, :with_maintenance_received, submission: cfe_submission) }

          it { is_expected.to eq "150.00" }
        end
      end

      context "when they do not receive maintenance" do
        context "with cfe version 3" do
          let!(:cfe_result) { create(:cfe_v3_result, submission: cfe_submission) }

          it { is_expected.to eq "0.00" }
        end

        context "with cfe version 4 result" do
          let!(:cfe_result) { create(:cfe_v4_result, submission: cfe_submission) }

          it { is_expected.to eq "0.00" }
        end
      end
    end
  end

  describe "#mortgage_per_month" do
    subject { legal_aid_application.applicant.mortgage_per_month }

    let(:legal_aid_application) { create(:legal_aid_application, :with_everything) }
    let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }

    context "when they pay a mortgage" do
      context "with cfe version 3 result" do
        let!(:cfe_result) { create(:cfe_v3_result, submission: cfe_submission) }

        it { is_expected.to eq "125.00" }

        context "when they do not pay a mortgage" do
          let!(:cfe_result) { create(:cfe_v4_result, submission: cfe_submission) }

          it { is_expected.to eq "0.00" }
        end
      end

      context "with cfe version 4 result" do
        let!(:cfe_result) { create(:cfe_v4_result, :with_mortgage_costs, submission: cfe_submission) }

        it { is_expected.to eq "120.00" }

        context "when they do not pay a mortgage" do
          let!(:cfe_result) { create(:cfe_v4_result, submission: cfe_submission) }

          it { is_expected.to eq "0.00" }
        end
      end
    end
  end

  describe "#valid_cfe_result_version?" do
    let(:applicant) { create(:applicant) }

    context "with CFE version 3 result" do
      let!(:legal_aid_application) { create(:legal_aid_application, :with_cfe_v3_result, applicant:) }

      it "returns true" do
        expect(applicant.valid_cfe_result_version?).to be true
      end
    end

    context "with CFE version 4 result" do
      let!(:legal_aid_application) { create(:legal_aid_application, :with_cfe_v4_result, applicant:) }

      it "returns true" do
        expect(applicant.valid_cfe_result_version?).to be true
      end
    end

    context "with CFE version 5 result" do
      let!(:legal_aid_application) { create(:legal_aid_application, :with_cfe_v5_result, applicant:) }

      it "returns true" do
        expect(applicant.valid_cfe_result_version?).to be true
      end
    end

    context "with CFE version out of scope result" do
      let!(:legal_aid_application) { create(:legal_aid_application, applicant:) }
      let(:cfe_version_5_result) { double "CFE::V5::Result" }

      before do
        allow_any_instance_of(described_class).to receive(:cfe_result_type).and_return(cfe_version_5_result)
      end

      it "returns false" do
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
          applicant = build(:applicant, :armed_forces)
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
end
