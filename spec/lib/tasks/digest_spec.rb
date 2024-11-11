require "rails_helper"

RSpec.describe "digest:", type: :task do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    allow(HostEnv).to receive(:staging_or_production?).and_return(staging_or_production)
    allow(Rails.logger).to receive(:info)
  end

  let(:staging_or_production) { true }

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
      before do
        allow(ENV).to receive(:fetch)
        allow(ENV).to receive(:fetch).with("BYPASS", nil).and_return(bypass)
      end

      let(:staging_or_production) { false }

      context "and the BYPASS value is missing" do
        let(:bypass) { nil }

        it "does not call the service" do
          task.execute
          expect(DigestExtractor).not_to have_received(:call)
          expect(Rails.logger).to have_received(:info).once
        end
      end

      context "and the BYPASS value is present" do
        let(:bypass) { "true" }

        it "calls the service" do
          task.execute
          expect(DigestExtractor).to have_received(:call)
        end
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
      before do
        allow(ENV).to receive(:fetch)
        allow(ENV).to receive(:fetch).with("BYPASS", nil).and_return(bypass)
      end

      let(:staging_or_production) { false }

      context "and the BYPASS value is missing" do
        let(:bypass) { nil }

        it "does not call the service" do
          task.execute
          expect(DigestExporter).not_to have_received(:call)
          expect(Rails.logger).to have_received(:info).once
        end
      end

      context "and the BYPASS value is present" do
        let(:bypass) { "true" }

        it "calls the service" do
          task.execute
          expect(DigestExporter).to have_received(:call)
        end
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
      before do
        allow(ENV).to receive(:fetch)
        allow(ENV).to receive(:fetch).with("BYPASS", nil).and_return(bypass)
      end

      let(:staging_or_production) { false }

      context "and the BYPASS value is missing" do
        let(:bypass) { nil }

        it "does not call the service" do
          task.execute
          expect(setting).not_to have_received(:update!)
          expect(Rails.logger).to have_received(:info).once
        end
      end

      context "and the BYPASS value is present" do
        let(:bypass) { "true" }

        it "calls the service" do
          task.execute
          expect(setting).to have_received(:update!)
        end
      end
    end
  end
end
