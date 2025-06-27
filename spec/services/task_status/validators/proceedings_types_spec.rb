require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::ProceedingsTypes, :vcr do
  subject(:validator) { described_class.new(application) }

  let(:application) { create(:application) }

  it_behaves_like "a task status validator"

  describe "#valid?" do
    context "when there are no proceedings" do
      let(:application) do
        create(:application).tap do |app|
          app.proceedings.destroy_all
          app.save!
        end
      end

      it { is_expected.not_to be_valid }
    end

    context "with single proceeding with a client involvement type" do
      let(:application) do
        create(:application).tap do |app|
          app.proceedings = [build(:proceeding, :da001, :with_cit_a)]
          app.save!
        end
      end

      it { is_expected.to be_valid }
    end

    context "with single proceeding without a client involvement type" do
      let(:application) do
        create(:application).tap do |app|
          app.proceedings = [build(:proceeding, :da001, :without_cit)]
          app.save!
        end
      end

      it { is_expected.not_to be_valid }
    end

    context "with multiple proceedings both with and without client involvement types" do
      let(:application) do
        create(:application).tap do |app|
          app.proceedings = [
            build(:proceeding, :da004, :with_cit_d),
            build(:proceeding, :da001, :without_cit),
          ]

          app.save!
        end
      end

      it { is_expected.not_to be_valid }
    end
  end
end
