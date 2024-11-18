require "rails_helper"

RSpec.describe "v1/attachments" do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:attachment) { create(:attachment, :uploaded_evidence_collection, legal_aid_application:) }

  describe "PATCH /v1/attachments/:id" do
    subject(:request) { patch v1_attachment_path(id), params: }

    let(:params) { { attachment: { type: "benefit_evidence" } } }

    context "when the attachment exists and valid type provided" do
      let(:id) { attachment.id }
      let(:params) { { attachment: { type: "benefit_evidence" } } }

      it "returns http success" do
        request
        expect(response).to have_http_status(:success)
      end

      it "updates the attachment's category" do
        expect { request }.to change { attachment.reload.attachment_type }
          .from("uncategorised")
          .to("benefit_evidence")
      end
    end

    context "when the attachment type is invalid" do
      let(:id) { attachment.id }
      let(:params) { { attachment: { type: "foobar" } } }

      it "returns http bad request" do
        request
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when the attachment does not exist" do
      let(:id) { SecureRandom.hex }

      it "returns http not found" do
        request
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
