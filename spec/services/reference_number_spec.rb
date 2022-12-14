require "rails_helper"

RSpec.describe ReferenceNumber do
  describe ".generate" do
    before do
      seed_random_generator
      stub_existing_reference_number(anything, nil)
    end

    it "generates unique numbers" do
      expect(described_class.generate).to eq("L-FL6-NCM")

      stub_existing_reference_number("L-TUF-JR9", true)

      expect(described_class.generate).to eq("L-VBC-XVP")
    end
  end

private

  def seed_random_generator
    Kernel.srand(1234)
  end

  def stub_existing_reference_number(reference_number, return_value)
    allow(LegalAidApplication)
      .to receive(:find_by)
      .with(application_ref: reference_number)
      .and_return(return_value)
  end
end
