require "rails_helper"

module FeatureFlag
  RSpec.describe PercentageToday do
    subject(:call) { described_class.call(object_class_name, number) }

    let(:object_class_name) { "LegalAidApplication" }

    context "when we want 10% of the object" do
      let(:number) { 10 }

      context "when 8 of the object already exist and we create the 9th" do
        before { create_list(:legal_aid_application, 9) }

        it { expect(call).to be false }
      end

      context "when 10 of the object exist" do
        before { create_list(:legal_aid_application, 10) }

        it { expect(call).to be true }
      end
    end

    context "when called for a different object" do
      let(:object_class_name) { "CFE::Submission" }

      context "and we want 20% to trigger" do
        let(:number) { 20 }

        before { create_list(:cfe_submission, 4) }

        it "will return true for the fifth and 10th objects" do
          expect(described_class.call(object_class_name, number)).to be false
          create(:cfe_submission) # 5th
          expect(described_class.call(object_class_name, number)).to be true
          create(:cfe_submission) # 6th
          expect(described_class.call(object_class_name, number)).to be false
          create_list(:cfe_submission, 3) # 7,8 & 9
          expect(described_class.call(object_class_name, number)).to be false
          create(:cfe_submission) # 10th
          expect(described_class.call(object_class_name, number)).to be true
        end
      end
    end

    context "when called for an object that has not been created today" do
      let(:number) { 20 }

      it { expect(call).to be false }
    end
  end
end
