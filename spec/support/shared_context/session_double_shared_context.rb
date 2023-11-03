# Idea from
# https://github.com/DFE-Digital/schools-experience/blob/master/spec/support/session_double.rb
#
RSpec.shared_context "with session double" do
  let(:session) { session_double }
  let(:session_double) { instance_double(ActionDispatch::Request::Session, enabled?: true, loaded?: false, id: SecureRandom.hex) }
  let(:session_hash) { {} }

  before do
    allow(session_double).to receive(:[]) do |key|
      session_hash[key]
    end

    allow(session_double).to receive(:[]=) do |key, value|
      session_hash[key] = value
    end

    allow(session_double).to receive(:delete) do |key|
      session_hash.delete(key)
    end

    allow(session_double).to receive(:clear) do |_key|
      session_hash.clear
    end

    allow(session_double).to receive(:fetch) do |key|
      session_hash.fetch(key)
    end

    allow(session_double).to receive(:key?) do |key|
      session_hash.key?(key)
    end

    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:session).and_return(session_double)
    # rubocop:enable RSpec/AnyInstance
  end
end
