require "rails_helper"

RSpec.describe PDA::MockProviderDetails do
  describe ".call" do
    subject(:call) { described_class.call(provider, office_code) }

    let(:office_code) { "0X395U" }

    after do
      # This mock service will enable mocking and stub requests in "production" code so we should
      # reset to avoid polluting other tests
      WebMock.reset!

      # Reload webmock config to reset webmock config (disallow_net_connect in particular)
      load Rails.root.join("spec/support/webmock_setup.rb")
    end

    context "when called with an office for the first time" do
      context "with expected stubbed user and offices response" do
        let(:provider) { create(:provider, username: "MARTIN.RONAN@DAVIDGRAY.CO.UK", firm: nil) }

        it "adds the provider to the expected firm" do
          expect { call }
            .to change { provider.reload.firm }
              .from(nil)
              .to(an_instance_of(Firm))

          expect(provider.firm).to have_attributes(name: "DAVID GRAY LLP", ccms_id: "19148")
        end

        it "adds the expected office to the provider" do
          expect { call }
            .to change { provider.reload.offices.count }.from(0).to(1)

          expect(provider.selected_office).to have_attributes(code: "0X395U", ccms_id: "137570")
        end

        it "marks the office as selected by provider" do
          expect { call }
            .to change { provider.reload.selected_office }.from(nil).to(an_instance_of(Office))

          expect(provider.selected_office).to have_attributes(code: "0X395U", ccms_id: "137570")
        end

        it "adds [only] applicable schedules to provider's selected office" do
          expect { call }.to change { provider.reload.selected_office&.schedules&.count }.from(nil).to(1)

          expect(provider.selected_office.schedules.first).to have_attributes(
            area_of_law: "LEGAL HELP",
            category_of_law: "MAT",
            authorisation_status: "APPROVED",
            status: "Open",
            cancelled: false,
            start_date: "2024-09-01".to_date,
            end_date: "2025-08-31".to_date,
            license_indicator: 1,
            devolved_power_status: "Yes - Excluding JR Proceedings",
          )
        end

        it "adds the CCMS contact_id to the provider" do
          expect { call }.to change { provider.reload.contact_id }.from(nil).to(234_567)
        end
      end
    end

    context "when called with an office for the second time, or more" do
      let(:provider) do
        create(:provider, username: "MARTIN.RONAN@DAVIDGRAY.CO.UK", contact_id: 654_321, firm:).tap do |provider|
          provider.offices << office
        end
      end

      let(:firm) { create(:firm, name: "original firm name", ccms_id: "19148") }
      let(:office) { create(:office, code: office_code, ccms_id: "12345") }

      it "updates the firm name of the provider" do
        expect { call }
          .to change { firm.reload.name }
            .from("original firm name")
            .to("DAVID GRAY LLP")
      end

      it "updates the office's CCMS id" do
        expect { call }
          .to change { office.reload.ccms_id }
            .from("12345")
            .to("137570")
      end

      it "updates the providers contact id" do
        expect { call }
          .to change { provider.reload.contact_id }
            .from(654_321)
            .to(234_567)
      end
    end
  end
end
