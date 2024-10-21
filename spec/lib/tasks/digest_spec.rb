require "rails_helper"

RSpec.describe "digest:", type: :task do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    allow(HostEnv).to receive(:uat?).and_return(false)
  end

  describe "extract" do
    subject(:task) { Rake::Task["digest:extract"] }

    before do
      allow(DigestExtractor).to receive(:call).and_return(nil)
    end

    it "calls the service" do
      task.execute
      expect(DigestExtractor).to have_received(:call)
    end

    context "when host env is uat" do
      before { allow(HostEnv).to receive(:uat?).and_return(true) }

      it "does not the service" do
        task.execute
        expect(DigestExtractor).not_to have_received(:call)
      end
    end
  end

  describe "export" do
    subject(:task) { Rake::Task["digest:export"] }

    before do
      allow(DigestExporter).to receive(:call).and_return(nil)
    end

    it "calls the service" do
      task.execute
      expect(DigestExporter).to have_received(:call)
    end

    context "when host env is uat" do
      before { allow(HostEnv).to receive(:uat?).and_return(true) }

      it "does not call the service" do
        task.execute
        expect(DigestExporter).not_to have_received(:call)
      end
    end
  end

  describe "extraction_date:reset" do
    subject(:task) { Rake::Task["digest:extraction_date:reset"] }

    let(:setting) { instance_double(Setting) }

    before do
      allow(Setting).to receive(:setting).and_return(setting)
      allow(setting).to receive(:update!)
    end

    it "calls the service" do
      task.execute
      expect(setting).to have_received(:update!)
    end

    context "when host env is uat" do
      before { allow(HostEnv).to receive(:uat?).and_return(true) }

      it "does not call the service" do
        task.execute
        expect(setting).not_to have_received(:update!)
      end
    end
  end
end
