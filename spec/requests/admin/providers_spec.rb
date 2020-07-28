require 'rails_helper'

module Admin
  RSpec.describe ProvidersController, type: :request do
    let(:admin_user) { create :admin_user }
    before { sign_in admin_user }

    describe 'GET admin/providers/new' do
      before { get new_admin_provider_path }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays Add new provider user page' do
        expect(response.body).to include('Add new provider user')
      end
    end

    describe 'POST admin/provider/check' do
      let(:params) { { provider: { username: username } } }
      let(:username) { 'stepriponikas bonstart' }
      let(:firm_name) { 'Cudmore and Fabby Ltd.' }

      before do
        expect(Admin::ProviderDetailsService).to receive(:new).and_return(service)
      end

      subject { post admin_provider_check_path, params: params }

      context 'ProviderDetailsService returns :success' do
        let(:service) { double Admin::ProviderDetailsService, check: :success, firm_name: firm_name }

        it 'renders successfully' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'renders the check page with the username and firm name' do
          subject
          expect(response.body).to include("Add provider user #{username}")
          expect(response.body).to include("User is in firm #{firm_name}")
        end
      end

      context 'ProviderDetailsService returns :error' do
        let(:service) { double Admin::ProviderDetailsService, check: :error, message: 'my error message' }

        it 'renders successfully' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'renders the check page with the username and firm name' do
          subject
          expect(response.body).to include('Add new provider user')
          expect(response.body).to include('my error message')
        end
      end
    end

    describe 'POST admin/providers' do
      let(:params) { { provider: { username: username } } }
      let(:username) { 'stepriponikas bonstart' }
      let(:firm_name) { 'Cudmore and Fabby Ltd.' }

      before do
        expect(Admin::ProviderDetailsService).to receive(:new).and_return(service)
      end

      subject { post admin_providers_path, params: params }

      context 'ProviderDetailsService returns :success' do
        let(:service) { double Admin::ProviderDetailsService, create: :success, firm_name: firm_name }
        it 'redirects' do
          subject
          expect(response).to redirect_to new_admin_provider_path
        end

        it 'renders the new page with a confirmatory flash message' do
          subject
          follow_redirect!
          expect(response.body).to include("User #{username} created")
          expect(response.body).to include('Add new provider user')
        end
      end

      context 'ProviderDetailsService returns :error' do
        let(:service) { double Admin::ProviderDetailsService, create: :error, message: 'my error message' }
        it 'redirects' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'renders the new page with the error message' do
          subject
          expect(response.body).to include('Add new provider user')
          expect(response.body).to include('my error message')
        end
      end
    end
  end
end
