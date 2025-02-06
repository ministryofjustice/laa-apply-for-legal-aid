require "rails_helper"

RSpec.describe "ptr_migrations:", type: :task do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    allow(Rails.logger).to receive(:info)
  end

  describe "ptr_migrations:laa_transfer_office" do
    subject(:task) do
      Rake::Task["ptr_migrations:laa_transfer_office"]
    end

    let(:initial_office) { create(:office) }
    let(:new_office) { create(:office) }
    let(:legal_aid_application) { create(:legal_aid_application, office: initial_office) }

    context "when LegalAidApplication and Office exist" do
      it "updates the office" do
        expect {
          task.execute(mock: "false", app_id: legal_aid_application.id, office_id: new_office.id)
        }.to change { legal_aid_application.reload.office }
        .from(initial_office).to(new_office)
      end

      it "logs an error message" do
        task.execute(mock: "false", app_id: legal_aid_application.id, office_id: new_office.id)

        expect(Rails.logger).to have_received(:info).with("LegalAidApplication (#{legal_aid_application.application_ref}) current office code: #{initial_office.code}")
        expect(Rails.logger).to have_received(:info).with("LegalAidApplication (#{legal_aid_application.application_ref}) successfully transferred to office code: #{new_office.code}")
      end
    end

    context "when LegalAidApplication does not exist" do
      it "does not update the office" do
        expect {
          task.execute(mock: "false", app_id: nil, office_id: new_office.id)
        }.not_to change { legal_aid_application.reload.office }
        .from(initial_office)
      end

      it "logs an error message" do
        task.execute(mock: "false", app_id: nil, office_id: new_office.id)

        expect(Rails.logger).to have_received(:info).with("LegalAidApplication or OFFICE does not exist")
      end
    end

    context "when Office does not exist" do
      it "does not update the office" do
        expect {
          task.execute(mock: "false", app_id: legal_aid_application.id, office_id: nil)
        }.not_to change { legal_aid_application.reload.office }
        .from(initial_office)
      end

      it "logs an error message" do
        task.execute(mock: "false", app_id: legal_aid_application.id, office_id: nil)

        expect(Rails.logger).to have_received(:info).with("LegalAidApplication or OFFICE does not exist")
      end
    end

    context "when both LegalAidApplication and Office do not exist" do
      it "does not update the office" do
        expect {
          task.execute(mock: "false", app_id: nil, office_id: nil)
        }.not_to change { legal_aid_application.reload.office }
        .from(initial_office)
      end

      it "logs an error message" do
        task.execute(mock: "false", app_id: nil, office_id: nil)

        expect(Rails.logger).to have_received(:info).with("LegalAidApplication or OFFICE does not exist")
      end
    end

    context "when mock is true" do
      it "does not update the office" do
        expect {
          task.execute(mock: "true", app_id: legal_aid_application.id, office_id: new_office.id)
        }.not_to change { legal_aid_application.reload.office }
        .from(initial_office)
      end

      it "logs errors messages" do
        task.execute(mock: "true", app_id: legal_aid_application.id, office_id: new_office.id)

        expect(Rails.logger).to have_received(:info).with("LegalAidApplication (#{legal_aid_application.application_ref}) current office code: #{initial_office.code}")
        expect(Rails.logger).to have_received(:info).with("LegalAidApplication (#{legal_aid_application.application_ref}) successfully transferred to office code: #{initial_office.code}")
      end
    end
  end

  describe "provider_transfer_firm" do
    subject(:task) do
      Rake::Task["ptr_migrations:provider_transfer_firm"]
    end

    let(:initial_firm) { create(:firm) }
    let(:new_firm) { create(:firm) }
    let(:provider) { create(:provider, firm: initial_firm) }

    context "when Provider and Firm exist" do
      it "updates the firm" do
        expect {
          task.execute(mock: "false", provider_id: provider.id, firm_id: new_firm.id)
        }.to change { provider.reload.firm }
        .from(initial_firm).to(new_firm)
      end

      it "logs a message" do
        task.execute(mock: "false", provider_id: provider.id, firm_id: new_firm.id)

        expect(Rails.logger).to have_received(:info).with("Provider (#{provider.email}) current firm #{initial_firm.name}")
        expect(Rails.logger).to have_received(:info).with("Provider (#{provider.email}) successfully transferred to firm #{new_firm.name}")
      end
    end

    context "when Provider does not exist" do
      it "does not update the firm" do
        expect {
          task.execute(mock: "false", provider_id: nil, firm_id: new_firm.id)
        }.not_to change { provider.reload.firm }
        .from(initial_firm)
      end

      it "logs a message" do
        task.execute(mock: "false", provider_id: nil, firm_id: new_firm.id)

        expect(Rails.logger).to have_received(:info).with("PROVIDER or FIRM does not exist")
      end
    end

    context "when Firm does not exist" do
      it "does not update the firm" do
        expect {
          task.execute(mock: "false", provider_id: provider.id, firm_id: nil)
        }.not_to change { provider.reload.firm }
        .from(initial_firm)
      end

      it "logs an error message" do
        task.execute(mock: "false", provider_id: provider.id, firm_id: nil)

        expect(Rails.logger).to have_received(:info).with("PROVIDER or FIRM does not exist")
      end
    end

    context "when both Provider and Firm do not exist" do
      it "does not update the firm" do
        expect {
          task.execute(mock: "false", provider_id: nil, firm_id: nil)
        }.not_to change { provider.reload.firm }
        .from(initial_firm)
      end

      it "logs a message" do
        task.execute(mock: "false", provider_id: nil, firm_id: nil)

        expect(Rails.logger).to have_received(:info).with("PROVIDER or FIRM does not exist")
      end
    end

    context "when mock is true" do
      it "does not update the firm" do
        expect {
          task.execute(mock: "true", provider_id: provider.id, firm_id: new_firm.id)
        }.not_to change { provider.reload.firm }
        .from(initial_firm)
      end

      it "logs a message" do
        task.execute(mock: "true", provider_id: provider.id, firm_id: new_firm.id)

        expect(Rails.logger).to have_received(:info).with("Provider (#{provider.email}) current firm #{initial_firm.name}")
        expect(Rails.logger).to have_received(:info).with("Provider (#{provider.email}) successfully transferred to firm #{initial_firm.name}")
      end
    end
  end

  describe "delete_firm_office" do
    subject(:task) do
      Rake::Task["ptr_migrations:delete_firm_office"]
    end

    let(:firm) { create(:firm) }
    let(:office) { create(:office) }

    before do
      firm.offices << office
    end

    context "when Firm exist and has no associated LegalAidApplications" do
      it "deletes the firm" do
        expect {
          task.execute(mock: "false", firm_id: firm.id)
        }.to change { Firm.exists?(firm.id) }
        .from(true).to(false)
      end

      it "logs a message" do
        task.execute(mock: "false", firm_id: firm.id)

        expect(Rails.logger).to have_received(:info).with("Firm (#{firm.name}), Office (#{office.code}) deleted successfully")
        expect(Rails.logger).to have_received(:info).with("Firm (#{firm.name}), deleted successfully")
      end
    end

    context "when Firm exist and Office has associated LegalAidApplications" do
      before do
        create(:legal_aid_application, office: office)
        create(:legal_aid_application, office: office)
      end

      it "does not delete the firm" do
        expect {
          task.execute(mock: "false", firm_id: firm.id)
        }.not_to change { Firm.exists?(firm.id) }
        .from(true)
      end

      it "logs a message" do
        task.execute(mock: "false", firm_id: firm.id)

        expect(Rails.logger).to have_received(:info).with("Firm (#{firm.name}), Office (#{office.code}) has 2 legal aid application associated with it. Skipping!")
        expect(Rails.logger).to have_received(:info).with("Firm (#{firm.name}) has 1 office associated with it. Skipping!")
      end
    end

    context "when Firm does not exist" do
      it "does not delete the firm" do
        expect {
          task.execute(mock: "false", firm_id: nil)
        }.not_to change { Firm.exists?(firm.id) }
        .from(true)
      end

      it "logs an error message" do
        task.execute(mock: "false", firm_id: nil)

        expect(Rails.logger).to have_received(:info).with("FIRM does not exist")
      end
    end

    context "when mock is true" do
      it "does not delete the firm" do
        expect {
          task.execute(mock: "false", firm_id: nil)
        }.not_to change { Firm.exists?(firm.id) }
        .from(true)
      end

      it "logs a message" do
        task.execute(mock: "true", firm_id: firm.id)

        expect(Rails.logger).to have_received(:info).with("Firm (#{firm.name}), Office (#{office.code}) deleted successfully")
        expect(Rails.logger).to have_received(:info).with("Firm (#{firm.name}) has 1 office associated with it. Skipping!")
      end
    end
  end
end
