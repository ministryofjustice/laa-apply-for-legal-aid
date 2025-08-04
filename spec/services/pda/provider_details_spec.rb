require "rails_helper"

RSpec.describe PDA::ProviderDetails do
  describe ".call" do
    subject(:call) { described_class.call(office.code) }

    before do
      firm.offices << office
      stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{office_code}/schedules")
        .to_return(body:, status:)
    end

    let(:firm) { create(:firm, name: "original firm name") }
    let(:office) { create(:office, code: office_code, ccms_id: "12345") }
    let(:office_code) { "4A497U" }

    context "when the office has schedules applicable to civil apply" do
      let(:status) { 200 }
      let(:body) do
        {
          firm: {
            firmId: 1639,
            ccmsFirmId: firm.ccms_id,
            firmName: "updated firm name",
          },
          office: {
            firmOfficeCode: "4A497U",
            ccmsFirmOfficeId: office.ccms_id,
          },
          schedules: [
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
          ],
        }.to_json
      end

      it "associates the contracts with the correct office" do
        expect { call }.to change { office.schedules.count }.from(0).to(1)
      end

      it "creates the schedules with the correct category of law" do
        expect(Rails.logger).to receive(:info).with("#{described_class} - Schedule LEGAL HELP MAT created for 4A497U")
        call
        expect(office.schedules.pluck(:category_of_law)).to contain_exactly("MAT")
      end

      it "updates the firm details" do
        call
        expect(firm.reload.name).to eq "updated firm name"
      end

      context "when the office code changes" do
        let(:office) { create(:office, code: "1A29C", ccms_id: "12345") }

        it "updates the office details" do
          described_class.call(office_code)
          expect(office.reload.code).to eq office_code
        end
      end
    end

    context "when the office does not have schedules applicable to civil apply" do
      let(:status) { 200 }
      let(:body) do
        {
          firm: {
            firmId: 1639,
            ccmsFirmId: firm.ccms_id,
          },
          office: {
            firmOfficeCode: "4A497U",
            ccmsFirmOfficeId: office.ccms_id,
          },
          schedules: [
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
          ],
        }.to_json
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
        call
        expect(office.schedules.count).to eq(0)
      end
    end

    context "when there is an error calling the api" do
      let(:body) { "An error has occurred" }
      let(:status) { 500 }

      it "raises ApiError" do
        expect { call }.to raise_error(PDA::ProviderDetails::ApiError, "API Call Failed: (500) An error has occurred")
      end
    end
  end
end
