RSpec.shared_examples "a reauthable model" do
  let(:record) { described_class.new(current_sign_in_at:) }

  describe "reauthenticate?" do
    subject { record.reauthenticate? }

    before do
      allow(record).to receive(:reauthenticate_in).and_return(5.minutes)
    end

    context "when `current_sign_in_at` has not exceeded the session lifespan" do
      let(:current_sign_in_at) { 3.minutes.ago }

      it { is_expected.to be(false) }
    end

    context "when `current_sign_in_at` has exceeded the session lifespan" do
      let(:current_sign_in_at) { 6.minutes.ago }

      it { is_expected.to be(true) }
    end
  end
end
