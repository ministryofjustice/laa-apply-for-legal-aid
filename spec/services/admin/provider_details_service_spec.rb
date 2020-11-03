require 'rails_helper'

module Admin
  RSpec.describe ProviderDetailsService do
    before do
      allow(Rails.configuration.x.provider_details).to receive(:url).and_return(dummy_provider_details_host)
      stub_request(:get, api_url).to_return(body: response_body, status: http_status)
    end

    let(:dummy_provider_details_host) { 'http://my_dummy_url/' }
    let(:provider) { Provider.new(username: username) }
    let(:api_url) { "#{dummy_provider_details_host}#{normalized_username}" }
    let(:normalized_username) { username.upcase.gsub(' ', '%20') }
    let(:username) { 'sarah smith' }
    let(:service) { described_class.new(provider) }

    shared_examples 'service handling error conditions' do
      context 'user already exists in providers table' do
        before { Provider.create(username: username) }
        let(:response_body) { nil }
        let(:http_status) { nil }

        it 'responds :error' do
          expect(subject).to eq :error
        end

        it 'explains in the message' do
          subject
          expect(service.message).to eq 'User sarah smith already exists in database'
        end
      end

      context 'username not on provider details api' do
        let(:response_body) { user_not_found_response.to_json }
        let(:http_status) { 404 }
        it 'responds :error' do
          expect(subject).to eq :error
        end

        it 'explains in message' do
          subject
          expect(service.message).to eq 'User sarah smith not known to CCMS'
        end
      end

      context 'other non-200 response' do
        let(:response_body) { '' }
        let(:http_status) { 505 }
        it 'responds :error' do
          expect(subject).to eq :error
        end

        it 'explains in message' do
          subject
          expect(service.message).to eq 'Bad response from Provider Details API: HTTP status 505'
        end
      end

      context 'username not in list of contacts' do
        let(:response_body) { missing_contact_response.to_json }
        let(:http_status) { 200 }
        it 'responds :error' do
          expect(subject).to eq :error
        end
        it 'explains in message' do
          subject
          expect(service.message).to eq 'No entry for user sarah smith found in list of contacts returned by CCMS'
        end
      end
    end

    describe '#check' do
      context 'errors' do
        subject { service.check }
        it_behaves_like 'service handling error conditions'
      end

      context 'user adds non-ascii characters to their name' do
        # we suspect that this comes from a cut and paste from MS into
        # the login box when parsed it returns BRAND%20NEW\u2011USER
        let(:username) { 'brand new‑user' }
        let(:response_body) { sarah_smith_response.to_json }
        let(:http_status) { 200 }

        subject { service.check }

        it 'responds with :error' do
          expect(subject).to eq :error
        end

        it 'displays an appropriate message' do
          subject
          expect(service.message).to eq "'brand new‑user' contains unicode characters, please re-type if cut and pasted"
        end
      end

      context 'success' do
        let(:http_status) { 200 }
        context 'username in list of contacts' do
          let(:response_body) { sarah_smith_response.to_json }
          it 'responds success' do
            expect(service.check).to eq :success
          end

          it 'puts firm name in message' do
            service.check
            expect(service.message).to eq 'User sarah smith confirmed for firm LOCAL LAW & CO LTD'
          end
        end
      end
    end

    describe '#create' do
      context 'errors' do
        subject { service.create }
        it_behaves_like 'service handling error conditions'
      end

      context 'success' do
        let(:http_status) { 200 }
        subject { service.create }
        context 'no firm or offices pre-exist' do
          let(:response_body) { sarah_smith_response.to_json }
          it 'creates the provider' do
            expect { subject }.to change { Provider.count }.by(1)
            expect(Provider.exists?(username: username)).to be true
          end

          it 'creates the firm linked to the provider' do
            expect { subject }.to change { Firm.count }.by(1)
            provider = Provider.find_by(username: username)
            firm = provider.firm
            expect(firm.ccms_id).to eq '24493'
          end

          it 'creates the offices linked to the firm' do
            expect { subject }.to change { Office.count }.by(2)
            firm = Firm.find_by(name: 'LOCAL LAW & CO LTD')
            offices = firm.offices.order(:code)
            expect(offices.size).to eq 2
            expect(offices.first.code).to eq '8B869F'
            expect(offices.first.ccms_id).to eq '81333'
            expect(offices.last.code).to eq '8M609S'
            expect(offices.last.ccms_id).to eq '146988'
          end
        end

        context 'firm and all offices pre-exist' do
          before do
            create_office firm, '146988', '8M609S'
            create_office firm, '81333', '8B869F'
          end
          let(:firm) { create_firm }
          let(:response_body) { sarah_smith_response.to_json }

          it 'creates the provider' do
            expect { subject }.to change { Provider.count }.by(1)
            expect(Provider.exists?(username: username)).to be true
          end

          it 'links the provider to the firm' do
            expect { subject }.not_to change { Firm.count }
            provider = Provider.find_by(username: username)
            expect(provider.firm).to eq firm
          end

          it 'does not add any offices' do
            expect { subject }.not_to change { Office.count }
          end
        end

        context 'firm and some offices pre-exist' do
          before do
            create_office firm, '81333', '8B869F'
          end
          let(:firm) { create_firm }
          let(:response_body) { sarah_smith_response.to_json }

          it 'creates the provider' do
            expect { subject }.to change { Provider.count }.by(1)
            expect(Provider.exists?(username: username)).to be true
          end

          it 'links the provider to the firm' do
            expect { subject }.not_to change { Firm.count }
            provider = Provider.find_by(username: username)
            expect(provider.firm).to eq firm
          end

          it 'creates the additional offices' do
            expect { subject }.to change { Office.count }.by(1)
            expect(firm.reload.offices.map(&:code)).to match_array(%w[8M609S 8B869F])
          end
        end
      end
    end

    def create_firm
      Firm.create(name: 'LOCAL LAW & CO LTD', ccms_id: '24493')
    end

    def create_office(firm, ccms_id, code)
      Office.create(firm: firm, ccms_id: ccms_id, code: code)
    end

    def sarah_smith_response
      {
        'providerFirmId' => 24_493,
        'contactUserId' => 47_096,
        'contacts' => [
          { 'id' => 3_043_807, 'name' => 'DENISE SAIK' },
          { 'id' => 5_870_075, 'name' => 'ISMAIL@LOCAL-LAW.COM' },
          { 'id' => 2_047_682, 'name' => 'SSALAM@LOCAL-LAW.COM' },
          { 'id' => 2_047_672, 'name' => 'CREID@LOCAL-LAW.COM' },
          { 'id' => 2_047_676, 'name' => 'MGUL@LOCAL-LAW.COM' },
          { 'id' => 3_043_805, 'name' => 'SARAH SMITH' },
          { 'id' => 3_178_792, 'name' => 'DJXANKAZTAL' }
        ],
        'feeEarners' => [],
        'providerOffices' => [
          { 'id' => '146988', 'name' => 'LOCAL LAW & CO LTD-8M609S' },
          { 'id' => '81333', 'name' => 'LOCAL LAW & CO LTD-8B869F' }
        ]
      }
    end

    def user_not_found_response
      {
        'timestamp' => '2020-07-28T10:52:01.141+0000',
        'status' => 404,
        'error' => 'Not Found',
        'message' => 'No records found for [SARAH%20SMITH]',
        'path' => '/api/providerDetails/SARAH%20SMITH'
      }
    end

    def missing_contact_response
      {
        'providerFirmId' => 24_493,
        'contactUserId' => 47_096,
        'contacts' => [
          { 'id' => 3_043_807, 'name' => 'DENISE SAIK' },
          { 'id' => 5_870_075, 'name' => 'ISMAIL@LOCAL-LAW.COM' },
          { 'id' => 2_047_682, 'name' => 'SSALAM@LOCAL-LAW.COM' },
          { 'id' => 2_047_672, 'name' => 'CREID@LOCAL-LAW.COM' },
          { 'id' => 2_047_676, 'name' => 'MGUL@LOCAL-LAW.COM' },
          { 'id' => 3_178_792, 'name' => 'DJXANKAZTAL' }
        ],
        'feeEarners' => [],
        'providerOffices' => [
          { 'id' => 146_988, 'name' => 'LOCAL LAW & CO LTD-8M609S' },
          { 'id' => 81_333, 'name' => 'LOCAL LAW & CO LTD-8B869F' }
        ]
      }
    end

    def additional_office_response
      {
        'providerFirmId' => 24_493,
        'contactUserId' => 47_096,
        'contacts' => [
          { 'id' => 3_043_807, 'name' => 'DENISE SAIK' },
          { 'id' => 5_870_075, 'name' => 'ISMAIL@LOCAL-LAW.COM' },
          { 'id' => 2_047_682, 'name' => 'SSALAM@LOCAL-LAW.COM' },
          { 'id' => 2_047_672, 'name' => 'CREID@LOCAL-LAW.COM' },
          { 'id' => 2_047_676, 'name' => 'MGUL@LOCAL-LAW.COM' },
          { 'id' => 3_043_805, 'name' => 'SARAH SMITH' },
          { 'id' => 3_178_792, 'name' => 'DJXANKAZTAL' }
        ],
        'feeEarners' => [],
        'providerOffices' => [
          { 'id' => '146988', 'name' => 'LOCAL LAW & CO LTD-8M609S' },
          { 'id' => '81333', 'name' => 'LOCAL LAW & CO LTD-8B869F' },
          { 'id' => '81334', 'name' => 'LOCAL LAW & CO LTD-8M609X' }
        ]
      }
    end
  end
end
