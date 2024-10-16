require "rails_helper"

module CFECivil
  RSpec.describe ComponentList do
    describe ".call" do
      subject(:call) { described_class.call(object) }

      context "when object is passported?" do
        let(:object) { instance_double(LegalAidApplication, passported?: true, non_passported?: true) }

        it "returns set of passported CFE::Service classes" do
          expect(call).to match([
            Components::Assessment,
            Components::ProceedingTypes,
            Components::Applicant,
            Components::Capitals,
            Components::Vehicles,
            Components::Properties,
            Components::ExplicitRemarks,
            Components::Partner,
          ])
        end
      end

      context "when object is non_passported? but not uploading_bank_statements?" do
        let(:object) { instance_double(CFE::Submission, passported?: false, non_passported?: true, client_uploading_bank_statements?: false) }

        it "returns set of non passported CFE::Service classes" do
          expect(call).to match([
            Components::Assessment,
            Components::ProceedingTypes,
            Components::Applicant,
            Components::Capitals,
            Components::Vehicles,
            Components::Properties,
            Components::ExplicitRemarks,
            Components::Dependants,
            Components::Outgoings,
            Components::StateBenefits,
            Components::OtherIncome,
            Components::IrregularIncomes,
            Components::Employments,
            Components::RegularTransactions,
            Components::CashTransactions,
            Components::Partner,
          ])
        end
      end

      context "when object is non_passported? and uploading_bank_statements?" do
        let(:object) { instance_double(LegalAidApplication, passported?: false, non_passported?: true, client_uploading_bank_statements?: true) }

        it "returns set of non passported CFE::Service classes" do
          expect(call).to match([
            Components::Assessment,
            Components::ProceedingTypes,
            Components::Applicant,
            Components::Capitals,
            Components::Vehicles,
            Components::Properties,
            Components::ExplicitRemarks,
            Components::Dependants,
            Components::IrregularIncomes,
            Components::Employments,
            Components::RegularTransactions,
            Components::CashTransactions,
            Components::Partner,
          ])
        end
      end

      context "when object is not passported? or non_passported?" do
        let(:object) { instance_double(CFE::Submission, passported?: false, non_passported?: false) }

        it { expect { call }.to raise_error(ArgumentError, %r{does not have a set of CFE submission services!}) }
      end
    end
  end
end
