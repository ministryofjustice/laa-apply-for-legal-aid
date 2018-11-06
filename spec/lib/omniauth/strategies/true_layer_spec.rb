require 'rails_helper'

module OmniAuth
  module Strategies
    RSpec.describe TrueLayer do
      let(:true_layer_root_url) { 'https://auth.truelayer.com' }

      subject { described_class.new({}) }

      it 'has the name true_layer' do
        expect(subject.name).to eq(:true_layer)
      end

      describe '#options.client_options' do
        let(:client_options) { subject.options.client_options }
        it 'has site set to true layer' do
          expect(client_options.site).to match(true_layer_root_url)
        end

        it 'has authorize url set to true layer' do
          expect(client_options.authorize_url).to match(true_layer_root_url)
        end

        it 'has correct token url' do
          expect(client_options.token_url).to match(true_layer_root_url)
          expect(client_options.token_url).to match('connect/token')
        end
      end

      describe '#authorize_params' do
        before do
          allow(subject).to receive(:session).and_return({})
        end
        it 'disables mock as default' do
          with_modified_env TRUE_LAYER_ENABLE_MOCK: nil do
            expect(subject.authorize_params[:enable_mock]).to be_falsey
          end
        end

        it 'can be set with an environment varialbe' do
          with_modified_env TRUE_LAYER_ENABLE_MOCK: 'true' do
            expect(subject.authorize_params[:enable_mock]).to be_truthy
          end
        end
      end

      describe '#token_params' do
        let(:callback_url) { 'http://example.com' }
        before do
          allow(subject).to receive(:callback_url).and_return(callback_url)
        end
        it 'contains the redirect uri' do
          expect(subject.token_params[:redirect_uri]).to eq(callback_url)
        end

        context 'with query included in callback' do
          let(:root_url) { 'http://example.com' }
          let(:callback_url) { "#{root_url}?foo=bar" }

          it 'strips off the query' do
            expect(subject.token_params[:redirect_uri]).to eq(root_url)
          end
        end
      end
    end
  end
end
