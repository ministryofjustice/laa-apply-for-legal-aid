require "rails_helper"

RSpec.describe MeansReportHelper do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application, applicant:) }
  let(:applicant) { build_stubbed(:applicant) }

  shared_examples "transaction type item list" do
    it { is_expected.to all(respond_to(:to_h)) }
  end

  describe "#outgoings_detail_items" do
    subject(:items) { outgoings_detail_items }

    it_behaves_like "transaction type item list"

    it "has expected items" do
      expect(items.map(&:name)).to eq(%i[housing childcare maintenance_out legal_aid])
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

    it "has expected items" do
      expect(items.map(&:name)).to eql(%i[dependants_allowance])
    end

    context "when application has partner with no contrary interest" do
      before do
        allow(applicant).to receive(:has_partner_with_no_contrary_interest?).and_return(true)
      end

      it "has expected items" do
        expect(items.map(&:name)).to eql(%i[dependants_allowance partner_allowance])
      end
    end
  end
end
