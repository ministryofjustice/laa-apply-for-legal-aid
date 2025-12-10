require "rails_helper"

RSpec.describe PDA::MockProviderDetailsUpdater do
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
        let(:provider) { create(:provider, :without_ccms_user_details, firm: nil, silas_id: "51cdbbb4-75d2-48d0-aaac-fa67f013c50a", with_office_selected: false) }

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
            end_date: "2099-12-31".to_date,
            license_indicator: 1,
            devolved_power_status: "Yes - Excluding JR Proceedings",
          )
        end

        it "updates the provider ccms_contact_id" do
          expect { call }.to change { provider.reload.ccms_contact_id }.from(nil).to(66_731_970)
        end
      end
    end

    context "when called with an office for the second time, or more" do
      let(:provider) do
        create(:provider, silas_id: "51cdbbb4-75d2-48d0-aaac-fa67f013c50a", ccms_contact_id: 654_321, username: "MY-CCMS-USERNAME", firm:, selected_office: old_office, with_office_selected: false).tap do |provider|
          provider.offices << old_office
          provider.save!
        end
      end

      let(:firm) { create(:firm, name: "original firm name", ccms_id: "19148") }
      let(:office) { create(:office, code: office_code, ccms_id: "12345") }
      let(:old_office) { create(:office) }

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

      it "update the provider's CCMS contact id" do
        expect { call }
          .to change { provider.reload.ccms_contact_id }
            .from(654_321)
            .to(66_731_970)
      end

      it "updates the provider's username" do
        expect { call }
          .to change { provider.reload.username }
            .from("MY-CCMS-USERNAME")
            .to("DGRAY-BRUCE-DAVID-GRA-LLP1")
      end

      it "updates the selected_office_id, if it was not before" do
        expect { call }
          .to change { provider.reload.selected_office }
            .from(old_office)
            .to(office)
      end

      context "when office was not selected previously" do
        before { provider.update!(selected_office: nil) }

        it "updates the selected_office_id, if it was not before" do
          expect { call }
            .to change { provider.reload.selected_office_id }
              .from(nil)
              .to(office.id)
        end
      end
    end
  end
end
