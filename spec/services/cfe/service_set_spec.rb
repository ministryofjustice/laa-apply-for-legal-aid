require "rails_helper"

# rubocop:disable RSpec/VerifiedDoubles
RSpec.describe CFE::ServiceSet do
  describe ".call" do
    subject(:call) { described_class.call(object) }

    context "when object is passported?" do
      let(:object) { double(Object, passported?: true, non_passported?: true) }

      it "returns set of passported CFE::Service classes" do
        expect(call).to match([
          CFE::CreateProceedingTypesService,
          CFE::CreateApplicantService,
          CFE::CreateCapitalsService,
          CFE::CreateVehiclesService,
          CFE::CreatePropertiesService,
          CFE::CreateExplicitRemarksService,
        ])
      end
    end

    context "when object is non_passported? but not uploading_bank_statements?" do
      let(:object) { double(Object, passported?: false, non_passported?: true, uploading_bank_statements?: false) }

      it "returns set of non passported CFE::Service classes" do
        expect(call).to match([
          CFE::CreateProceedingTypesService,
          CFE::CreateApplicantService,
          CFE::CreateCapitalsService,
          CFE::CreateVehiclesService,
          CFE::CreatePropertiesService,
          CFE::CreateExplicitRemarksService,
          CFE::CreateDependantsService,
          CFE::CreateOutgoingsService,
          CFE::CreateStateBenefitsService,
          CFE::CreateOtherIncomeService,
          CFE::CreateIrregularIncomesService,
          CFE::CreateEmploymentsService,
          CFE::CreateCashTransactionsService,
        ])
      end
    end

    context "when object is non_passported? and uploading_bank_statements?" do
      let(:object) { double(Object, passported?: false, non_passported?: true, uploading_bank_statements?: true) }

      it "returns set of non passported CFE::Service classes" do
        expect(call).to match([
          CFE::CreateProceedingTypesService,
          CFE::CreateApplicantService,
          CFE::CreateCapitalsService,
          CFE::CreateVehiclesService,
          CFE::CreatePropertiesService,
          CFE::CreateExplicitRemarksService,
          CFE::CreateDependantsService,
          CFE::CreateIrregularIncomesService,
          CFE::CreateEmploymentsService,
          CFE::CreateRegularTransactionsService,
          CFE::CreateCashTransactionsService,
        ])
      end
    end

    context "when object is not passported? or non_passported?" do
      let(:object) { double(Object, passported?: false, non_passported?: false) }

      it { expect { call }.to raise_error(ArgumentError, %r{does not have a set of CFE submission services!}) }
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
