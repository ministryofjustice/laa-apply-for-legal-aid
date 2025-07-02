require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::MakeLink do
  subject(:validator) { described_class.new(application) }

  let(:application) { create(:application) }

  let(:complete_applicant) do
    create(
      :applicant,
      has_national_insurance_number: true,
      national_insurance_number: "JA123456D",
      applied_previously: false,
      previous_reference: nil,
      correspondence_address_choice: "home",
      addresses: [build(:address, location: "home", lookup_used: true)],
      employed: nil,
    )
  end

  it_behaves_like "a task status validator"

  describe "#valid?" do
    let(:application) { create(:application, applicant:) }

    context "with all applicant details and client's UK home address supplied via looked up" do
      let(:applicant) { complete_applicant }

      it { is_expected.to be_valid }
    end

    context "with all applicant details and an office correspondence address, no care of recipient and no fixed residence status" do
      let(:applicant) do
        complete_applicant.update!(
          correspondence_address_choice: "office",
          no_fixed_residence: true,
          addresses: [build(:address, location: "correspondence", care_of: "no")],
        )
        complete_applicant
      end

      it { is_expected.to be_valid }
    end

    context "with all applicant details and a client's other Uk residence address, care of recipient, residence status and home address" do
      let(:applicant) do
        complete_applicant.update!(
          correspondence_address_choice: "residence",
          no_fixed_residence: false,
          addresses: [
            build(:address, location: "correspondence", lookup_used: true, care_of: "person", care_of_first_name: "Solly", care_of_last_name: "Icitor"),
            build(:address, location: "home", lookup_used: true),
          ],
        )
        complete_applicant
      end

      it { is_expected.to be_valid }
    end

    context "with all applicant details and a client's other Uk residence address but missing fixed resident status" do
      let(:applicant) do
        complete_applicant.update!(
          correspondence_address_choice: "residence",
          no_fixed_residence: nil,
          addresses: [build(:address, location: "correspondence", lookup_used: true, care_of: "no")],
        )
        complete_applicant
      end

      it { is_expected.not_to be_valid }
    end

    context "with no applicant" do
      let(:applicant) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with invalid first_name" do
      let(:applicant) do
        complete_applicant.update!(first_name: nil)
        complete_applicant
      end

      it { expect(validator).not_to be_valid }
    end

    context "with invalid last_name" do
      let(:applicant) do
        complete_applicant.update!(last_name: nil)
        complete_applicant
      end

      it { expect(validator).not_to be_valid }
    end

    context "with invalid changed_last_name" do
      let(:applicant) do
        complete_applicant.update!(changed_last_name: nil)
        complete_applicant
      end

      it { expect(validator).not_to be_valid }
    end

    context "with invalid date_of_birth" do
      let(:applicant) do
        complete_applicant.update!(date_of_birth: nil)
        complete_applicant
      end

      it { expect(validator).not_to be_valid }
    end

    context "with invalid has_national_insurance_number" do
      let(:applicant) do
        complete_applicant.update!(has_national_insurance_number: nil)
        complete_applicant
      end

      it { is_expected.not_to be_valid }
    end

    context "with invalid national_insurance_number" do
      let(:applicant) do
        complete_applicant.update!(national_insurance_number: "JA")
        complete_applicant
      end

      it { is_expected.not_to be_valid }
    end

    context "with invalid applied_previously" do
      let(:applicant) do
        complete_applicant.update!(applied_previously: nil)
        complete_applicant
      end

      it { is_expected.not_to be_valid }
    end

    context "with invalid previous_reference" do
      let(:applicant) do
        complete_applicant.update!(applied_previously: true, previous_reference: nil)
        complete_applicant
      end

      it { is_expected.not_to be_valid }
    end
  end
end
