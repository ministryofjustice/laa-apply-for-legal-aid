require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#translation_exists_for?' do
    context 'translation exists' do
      it 'returns true' do
        expect(translation_exists_for?('generic.accept_and_send')).to be true
      end
    end

    context 'translation does not exist' do
      it 'returns false' do
        expect(translation_exists_for?('generic.accept_and_send_xxxxxxxxxx')).to be false
      end
    end
  end
end
