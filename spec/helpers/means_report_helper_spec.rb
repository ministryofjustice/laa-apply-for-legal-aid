require "rails_helper"

RSpec.describe MeansReportHelper do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application, applicant:) }
  let(:applicant) { build_stubbed(:applicant) }

  shared_examples "transaction type item list" do
    it { is_expected.to all(respond_to(:to_h)) }
  end

  describe "#outgoings_detail_items" do
    subject(:items) { outgoings_detail_items(legal_aid_application) }

    it_behaves_like "transaction type item list"

    it "has expected items" do
      expect(items.map(&:name)).to eq(%i[housing childcare maintenance_out legal_aid])
    end

    context "with housing item" do
      subject(:housing_item) { items.first }

      context "when an application is uploading_bank_statements?" do
        before do
          allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(true)
        end

        it "addendum matches expected text" do
          expect(housing_item.addendum).to eq(" (any declared housing benefits have been deducted from this total)")
        end
      end

      context "when an application is not uploading_bank_statements?" do
        before do
          allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(false)
        end

        it "addendum is nil" do
          expect(housing_item.addendum).to be_nil
        end
      end
    end
  end

  describe "#income_detail_items" do
    subject(:items) { income_detail_items(legal_aid_application) }

    before do
      allow(applicant).to receive(:employed?).and_return(false)
    end

    it_behaves_like "transaction type item list"

    context "when applicant is employed?" do
      before { allow(applicant).to receive(:employed?).and_return(true) }

      it "has expected items" do
        expect(items.map(&:name)).to eql(%i[employment
                                            income_tax
                                            national_insurance
                                            fixed_employment_deduction
                                            benefits
                                            family_help
                                            maintenance_in
                                            property_or_lodger
                                            student_loan
                                            pension])
      end
    end

    context "when applicant is not employed?" do
      before { allow(applicant).to receive(:employed?).and_return(false) }

      it "has expected items" do
        expect(items.map(&:name)).to eql(%i[benefits family_help maintenance_in property_or_lodger student_loan pension])
      end
    end
  end

  describe "#deductions_detail_items" do
    subject(:items) { deductions_detail_items(legal_aid_application) }

    it_behaves_like "transaction type item list"

    context "when application is not uploading_bank_statements?" do
      before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(false) }

      it "has expected items" do
        expect(items.map(&:name)).to eql(%i[dependants_allowance disregarded_state_benefits])
      end
    end

    context "when application is uploading_bank_statements?" do
      before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(true) }

      it "has expected items" do
        expect(items.map(&:name)).to eql(%i[dependants_allowance])
      end
    end
  end
end
