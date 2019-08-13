require 'rails_helper'

RSpec.describe Admin::BenefitTypesController, type: :request do
  let!(:benefit_type) { create :benefit_type }
  let(:admin_user) { create :admin_user }
  let(:sign_in_user) { sign_in admin_user }
  let(:error_i18n_scope) { 'activerecord.errors.models.benefit_type.attributes' }

  before do
    sign_in_user
  end

  describe 'GET /admin/benefit_types' do
    subject { get admin_benefit_types_path }

    before { subject }

    it 'renders successfully' do
      expect(response).to have_http_status(200)
    end

    it 'displays existing benefit type' do
      expect(unescaped_response_body).to include(benefit_type.description)
    end

    context 'without sign in' do
      let(:sign_in_user) { nil }

      it 'redirects to sign in' do
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end

  describe 'POST /admin/benefit_types' do
    let(:params) { { benefit_type: attributes_for(:benefit_type) } }
    let(:created_benefit_type) { BenefitType.order(:created_at).last }

    subject { post admin_benefit_types_path, params: params }

    it 'creates new benefit type' do
      expect { subject }.to change { BenefitType.count }.by(1)
    end

    it 'redirects to show benefit type' do
      subject
      expect(response).to redirect_to(admin_benefit_type_path(created_benefit_type))
    end

    context 'with an existing label' do
      let(:params) do
        { benefit_type: attributes_for(:benefit_type).merge(label: benefit_type.label) }
      end

      it 'does not create a benefit type' do
        expect { subject }.not_to change { BenefitType.count }
      end

      it 'shows error page' do
        subject
        expect(response).to have_http_status(200)
        expect(unescaped_response_body).to include(I18n.t('label.taken', scope: error_i18n_scope))
      end
    end

    context 'with nothing submitted' do
      let(:params) { { benefit_type: {} } }

      it 'does not create a benefit type' do
        expect { subject }.not_to change { BenefitType.count }
      end

      it 'shows error page' do
        subject
        expect(response).to have_http_status(200)
        expect(unescaped_response_body).to include(I18n.t('label.blank', scope: error_i18n_scope))
      end
    end
  end

  describe 'GET /admin/benefit_types/new' do
    subject { get new_admin_benefit_type_path }

    before { subject }

    it 'renders successfully' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /admin/benefit_types/:id/edit' do
    subject { get edit_admin_benefit_type_path(benefit_type) }

    before { subject }

    it 'renders successfully' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /admin/benefit_types/:id' do
    subject { get admin_benefit_type_path(benefit_type) }

    before { subject }

    it 'renders successfully' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'PATCH /admin/benefit_types/:id' do
    let(:description) { Faker::Lorem.paragraph }
    let(:params) do
      { benefit_type: { description: description } }
    end

    subject { patch admin_benefit_type_path(benefit_type), params: params }

    before { subject }

    it 'updates benefit type' do
      expect(benefit_type.reload.description).to eq(description)
    end

    it 'redirects to show' do
      expect(response).to redirect_to(admin_benefit_type_path(benefit_type))
    end

    context 'with empty input' do
      let(:description) { '' }

      it 'shows error page' do
        expect(response).to have_http_status(200)
        expect(unescaped_response_body).to include(I18n.t('description.blank', scope: error_i18n_scope))
      end
    end
  end

  describe 'DELETE /admin/benefit_types/:id' do
    subject { delete admin_benefit_type_path(benefit_type) }

    it 'deletes the benefit type' do
      expect { subject }.to change { BenefitType.count }.by(-1)
    end

    it 'redirects to index' do
      subject
      expect(response).to redirect_to(admin_benefit_types_path)
    end
  end
end
