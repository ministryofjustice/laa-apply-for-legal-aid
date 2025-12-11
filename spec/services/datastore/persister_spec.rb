require "rails_helper"
RSpec.describe Datastore::Persister do
  subject(:instance) { described_class.new(legal_aid_application, response:, datastore_id:) }

  describe ".call" do
    subject(:call) { described_class.call(legal_aid_application, response:, datastore_id:) }

    let(:legal_aid_application) { create(:legal_aid_application) }
    let(:response) { instance_double(Faraday::Response, status: 201, body: "", headers: { "location" => "https://main-laa-data-access-api-uat.cloud-platform.service.justice.gov.uk/api/v0/applications/2dca0260-63bd-4d24-b266-e78ef169d8ec" }) }
    let(:datastore_id) { "2dca0260-63bd-4d24-b266-e78ef169d8ec" }

    it "stores the datastore id against the legal aid application" do
      expect { call }
        .to change { legal_aid_application.reload.datastore_id }
          .from(nil)
          .to("2dca0260-63bd-4d24-b266-e78ef169d8ec")
    end

    it "stores the datastore response as a relation on the legal aid application" do
      expect { call }
        .to change { legal_aid_application.reload.datastore_submissions }
          .from([])
          .to(
            [
              an_object_having_attributes(
                status: 201,
                body: "",
                headers: { "location" => "https://main-laa-data-access-api-uat.cloud-platform.service.justice.gov.uk/api/v0/applications/2dca0260-63bd-4d24-b266-e78ef169d8ec" },
              ),
            ],
          )
    end

    context "when no datastore id is provided" do
      let(:datastore_id) { nil }

      it "does not update the legal aid application's datastore id" do
        expect { call }
          .not_to change { legal_aid_application.reload.datastore_id }
            .from(nil)
      end
    end
  end
end
