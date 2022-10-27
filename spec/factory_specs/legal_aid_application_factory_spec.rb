require "rails_helper"

RSpec.describe "LegalAidApplication factory" do
  describe ":with_bank_accounts" do
    context "when used with :with_applicant" do
      context "with applicant not specified" do
        it "has no applicant" do
          legal_aid_application = create(:legal_aid_application)
          expect(legal_aid_application.applicant).to be_nil
        end
      end

      context "when :with_applicant specified" do
        context "and :with_bank_accounts not specified" do
          it "has an applicant but no bank accounts" do
            legal_aid_application = create(:legal_aid_application, :with_applicant)
            expect(legal_aid_application.applicant).to be_present
            expect(legal_aid_application.applicant.bank_accounts).to be_empty
          end
        end

        context "when :with_bank_accounts specified" do
          it "has the specified number of bank accounts" do
            legal_aid_application = create(:legal_aid_application, :with_applicant, with_bank_accounts: 3)
            expect(legal_aid_application.applicant).to be_present
            expect(legal_aid_application.applicant.bank_accounts.size).to eq 3
          end
        end
      end
    end

    describe "when used :with_everything" do
      context "and :with_bank_accounts not specified" do
        it "creates applicant but no bank accounts" do
          legal_aid_application = create(:legal_aid_application, :with_everything)
          expect(legal_aid_application.applicant).to be_present
          expect(legal_aid_application.applicant.bank_accounts).to be_empty
        end
      end

      context "when :with_bank_accounts specified" do
        it "creates applicant and the specified number of bank accounts" do
          legal_aid_application = create(:legal_aid_application, :with_everything, with_bank_accounts: 2)
          expect(legal_aid_application.applicant).to be_present
          expect(legal_aid_application.applicant.bank_accounts.size).to eq 2
        end
      end
    end
  end
end
