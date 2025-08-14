require "rails_helper"

RSpec.describe PDA::ProviderDetailsUpdater do
  describe ".call" do
    subject(:call) { described_class.call(provider, office.code) }

    before do
      firm.offices << office if office
      stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{office_code}/schedules")
        .to_return(body:, status:)
      stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-users/#{provider.username}")
        .to_return(body: user, status:)
    end

    let(:provider) { create(:provider) }
    let(:firm) { create(:firm, name: "original firm name", ccms_id: "56789") }
    let(:office) { create(:office, code: office_code, ccms_id: "12345") }
    let(:office_code) { "4A497U" }
    let(:ccms_office_id) { 12_345 }
    let(:ccms_firm_id) { 56_789 }
    let(:status) { 200 }

    let(:schedules) do
      [
        {
          contractType: "Standard",
          contractStatus: "Open",
          contractAuthorizationStatus: "APPROVED",
          contractStartDate: "2024-09-01",
          contractEndDate: "2026-06-30",
          areaOfLaw: "LEGAL HELP",
          scheduleType: "Standard",
          scheduleAuthorizationStatus: "APPROVED",
          scheduleStatus: "Open",
          scheduleStartDate: "2024-09-01",
          scheduleEndDate: "2025-08-31",
          scheduleLines: [
            {
              areaOfLaw: "LEGAL HELP",
              categoryOfLaw: "MAT",
              description: "Legal Help (Civil).Family",
              devolvedPowersStatus: "Yes - Excluding JR Proceedings",
              dpTypeOfChange: nil,
              dpReasonForChange: nil,
              dpDateOfChange: nil,
              remainderWorkFlag: "N/A",
              minimumCasesAllowedCount: "0",
              maximumCasesAllowedCount: "0",
              minimumToleranceCount: "0",
              maximumToleranceCount: "0",
              minimumLicenseCount: "0",
              maximumLicenseCount: "1",
              workInProgressCount: "0",
              outreach: nil,
              cancelFlag: "N",
              cancelReason: nil,
              cancelDate: nil,
              closedDate: nil,
              closedReason: nil,
            },
          ],
          nmsAuths: [],
        },
      ]
    end

    let(:body) do
      {
        firm: {
          firmId: 1639,
          ccmsFirmId: ccms_firm_id,
          firmName: "updated firm name",
        },
        office: {
          firmOfficeCode: "4A497U",
          ccmsFirmOfficeId: ccms_office_id,
        },
        schedules:,
      }.to_json
    end

    let(:user) do
      {
        user: {
          userId: 98_765,
          ccmsContactId: 87_654,
          userLogin: provider.username,
        },
      }.to_json
    end

    context "when the office has schedules applicable to civil apply" do
      it "associates the contracts with the correct office" do
        expect { call }.to change { office.schedules.count }.from(0).to(1)
      end

      it "creates the schedules with the correct category of law" do
        expect(Rails.logger).to receive(:info).with("#{described_class} - Schedule LEGAL HELP MAT created for 4A497U")
        call
        expect(office.schedules.pluck(:category_of_law)).to contain_exactly("MAT")
      end

      it "updates the firm details" do
        expect { call }
          .to change { firm.reload.name }
            .from("original firm name")
            .to("updated firm name")
      end

      it "updates the provider contact_id" do
        expect { call }.to change { provider.reload.contact_id }.from(nil).to(87_654)
      end

      context "when the office ccms_id changes" do
        let(:ccms_office_id) { 54_321 }

        it "updates the office details" do
          described_class.call(provider, office_code)
          office.reload
          expect(office.firm).to eq firm
          expect(office.code).to eq office_code
          expect(office.ccms_id).to eq "54321"
          expect(office.schedules.count).to eq 1
        end
      end

      context "when the office does not exist" do
        before { firm.offices = [] }

        let(:office) { nil }

        it "creates the office" do
          described_class.call(provider, office_code)
          office = Office.find_by(code: office_code)
          expect(office.firm).to eq firm
          expect(office.ccms_id).to eq "12345"
          expect(office.schedules.count).to eq 1
        end
      end

      context "when the firm does not exist" do
        let(:firm) { nil }
        let(:office) { nil }

        it "creates the firm" do
          described_class.call(provider, office_code)
          firm = Firm.find_by(ccms_id: "56789")
          expect(firm.name).to eq "updated firm name"
          expect(firm.offices.count).to eq 1
        end

        it "creates the office" do
          described_class.call(provider, office_code)
          office = Office.find_by(code: office_code)
          expect(office.ccms_id).to eq "12345"
          expect(office.schedules.count).to eq 1
        end
      end

      context "when there are existing schedules belonging to the office" do
        before { office.schedules << Schedule.new(area_of_law: "Legal Help", category_of_law: "HOU") }

        it "deletes any existing schedules belonging to the office" do
          call
          expect(office.schedules.pluck(:category_of_law)).to contain_exactly("MAT")
        end
      end
    end

    context "when the office does not have schedules applicable to civil apply" do
      let(:schedules) do
        [
          {
            contractType: "Standard",
            contractStatus: "Open",
            contractAuthorizationStatus: "APPROVED",
            contractStartDate: "2024-09-01",
            contractEndDate: "2026-06-30",
            areaOfLaw: "LEGAL HELP",
            scheduleType: "Standard",
            scheduleAuthorizationStatus: "APPROVED",
            scheduleStatus: "Open",
            scheduleStartDate: "2024-09-01",
            scheduleEndDate: "2025-08-31",
            scheduleLines: [
              {
                areaOfLaw: "LEGAL HELP",
                categoryOfLaw: "HOU",
                description: "Legal Help (Civil).Housing",
                devolvedPowersStatus: "No",
                dpTypeOfChange: nil,
                dpReasonForChange: nil,
                dpDateOfChange: nil,
                remainderWorkFlag: "No",
                minimumCasesAllowedCount: "0",
                maximumCasesAllowedCount: "0",
                minimumToleranceCount: "0",
                maximumToleranceCount: "0",
                minimumLicenseCount: "0",
                maximumLicenseCount: "0",
                workInProgressCount: "0",
                outreach: nil,
                cancelFlag: "N",
                cancelReason: nil,
                cancelDate: nil,
                closedDate: nil,
                closedReason: nil,
              },
            ],
            nmsAuths: [],
          },
          {
            contractType: "Standard",
            contractStatus: "Open",
            contractAuthorizationStatus: "APPROVED",
            contractStartDate: "2022-10-01",
            contractEndDate: "2025-09-30",
            areaOfLaw: "CRIME LOWER",
            scheduleType: "Standard",
            scheduleAuthorizationStatus: "APPROVED",
            scheduleStatus: "Open",
            scheduleStartDate: "2023-10-01",
            scheduleEndDate: "2025-09-30",
            scheduleLines: [
              {
                areaOfLaw: "CRIME LOWER",
                categoryOfLaw: "INVEST",
                description: "Crime Lower.Criminal Investigations and Criminal Proceedings",
                devolvedPowersStatus: nil,
                dpTypeOfChange: nil,
                dpReasonForChange: nil,
                dpDateOfChange: nil,
                remainderWorkFlag: nil,
                minimumCasesAllowedCount: "0",
                maximumCasesAllowedCount: "1",
                minimumToleranceCount: nil,
                maximumToleranceCount: nil,
                minimumLicenseCount: nil,
                maximumLicenseCount: nil,
                workInProgressCount: "0",
                outreach: nil,
                cancelFlag: "N",
                cancelReason: nil,
                cancelDate: nil,
                closedDate: nil,
                closedReason: nil,
              },
            ],
            nmsAuths: [],
          },
        ]
      end

      it "does not create any schedules" do
        expect(Rails.logger).to receive(:info).with("#{described_class} - No applicable schedules found for 4A497U")
        call
        expect(office.schedules.count).to eq(0)
      end
    end

    context "when PDA returns that the office does not have any schedules" do
      let(:status) { 204 }
      let(:body) { "" }

      it "does not create any schedules" do
        expect(Rails.logger).to receive(:info).with("#{described_class} - No schedules found for 4A497U")
        expect { call }.not_to change(office.schedules, :count)
      end

      context "when there are existing schedules belonging to the office" do
        before { office.schedules << Schedule.new(area_of_law: "Legal Help", category_of_law: "MAT") }

        it "deletes any existing schedules belonging to the office" do
          expect { call }.to change(office.schedules, :count).to(0)
        end
      end
    end

    context "when PDA returns no details for the provider user" do
      before { stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-users/#{provider.username}").to_return(body: "", status: 204) }

      it "raises a UserNotFound error" do
        expect(Rails.logger).to receive(:info).with("#{described_class} - No provider details found for #{provider.email}")
        expect { call }.to raise_error(PDA::ProviderDetailsUpdater::UserNotFound, "No CCMS username found for #{provider.email}")
      end

      context "when there is an error calling the provider-users endpoint" do
        before { stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-users/#{provider.username}").to_return(body: "An error has occurred", status: 500) }

        it "raises ApiError" do
          expect { call }.to raise_error(PDA::ProviderDetailsUpdater::ApiError, "API Call Failed: provider-users (500) An error has occurred")
        end
      end
    end

    context "when there is an error calling the provider-offices schedules endpoint" do
      let(:body) { "An error has occurred" }
      let(:status) { 500 }

      it "raises ApiError" do
        expect { call }.to raise_error(PDA::ProviderDetailsUpdater::ApiError, "API Call Failed retrieving office schedules: (500) An error has occurred")
      end
    end
  end
end
