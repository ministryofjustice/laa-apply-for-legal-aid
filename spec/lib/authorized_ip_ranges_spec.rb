require 'rails_helper'

RSpec.describe AuthorizedIpRanges do
  describe '#authorized?' do
    subject { AuthorizedIpRanges.new.authorized?(ipaddr) }

    context 'IPV4' do
      context 'authorized address' do
        let(:ipaddr) { '127.0.0.1' }
        it 'is authorised' do
          expect(subject).to be true
        end
      end

      context 'unauthorized address' do
        let(:ipaddr) { '250.155.1.66' }
        it 'is not authorised' do
          expect(subject).to be false
        end
      end
    end

    context 'IPV6' do
      context 'authorized address' do
        let(:ipaddr) { '::1' }
        it 'is authorised' do
          expect(subject).to be true
        end
      end

      context 'unauthorized address' do
        let(:ipaddr) { 'fdaa:bbcc:ddee:0:14c3:d7c5:9d07:195c' }
        it 'is not authorised' do
          expect(subject).to be false
        end
      end
    end
  end
end
