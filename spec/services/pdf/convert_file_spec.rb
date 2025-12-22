require "rails_helper"

module PDF
  RSpec.describe ConvertFile do
    subject(:call) { described_class.call(file) }

    before { allow(Libreconv).to receive(:convert) }

    describe "#call" do
      let(:filepath) { Rails.root.join("spec/fixtures/files/documents/hello_world.pdf").to_s }
      let(:file) { File.open(filepath) }

      it "returns a file object" do
        expect(call).to be_a Tempfile
      end

      it "calls Libreconv" do
        call
        expect(Libreconv).to have_received(:convert)
      end
    end
  end
end
