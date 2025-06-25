RSpec.shared_examples "a task status validator" do
  describe "#valid?" do
    it { expect(validator).to respond_to(:valid?) }
  end
end
