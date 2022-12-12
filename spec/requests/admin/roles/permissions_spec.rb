require "rails_helper"

RSpec.describe Admin::Roles::PermissionsController do
  let(:admin_user) { create(:admin_user) }
  let!(:firm) { create(:firm, name: "McKenzie, Brackman, Chaney and Kuzak") }

  before { sign_in admin_user }

  describe "GET index" do
    subject { get admin_roles_permission_path(firm.id) }

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "displays correct heading" do
      subject
      expect(response.body).to include(I18n.t("admin.roles.permissions.show.heading_1", firm_name: firm.name))
    end
  end

  describe "PATCH /index" do
    subject { patch admin_roles_permission_path(firm.id), params: params.merge }

    let(:params) { {} }

    context "when Save and Continue button pressed with no changes" do
      it "redirects to main admin page" do
        expect(subject).to redirect_to(admin_root_path)
      end
    end

    context "when Save and Continue button pressed with new permission changes" do
      let!(:permission) { create(:permission) }
      let!(:params) do
        {
          firm: {
            permission_ids: [permission.id],
          },
        }
      end

      it "saves the new permission" do
        expect { subject }.to change { firm.permissions.count }.by(1)
      end
    end
  end
end
