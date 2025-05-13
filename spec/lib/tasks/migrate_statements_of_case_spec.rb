require "rails_helper"

RSpec.describe "migrate:statements_of_case", type: :task do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["migrate:statements_of_case"].reenable
  end

  describe "migrate:statements_of_case" do
    subject(:task) { Rake::Task["migrate:statements_of_case"] }

    before { statement_of_case }

    context "when a statement of case exists with only text" do
      let(:statement_of_case) { create(:statement_of_case) }

      it "logs the expected output" do
        expect(Rails.logger).to receive(:info).with("== Before migration")
        expect(Rails.logger).to receive(:info).with("Affected applications: 1")
        expect(Rails.logger).to receive(:info).with("Number with text statement: 1")
        expect(Rails.logger).to receive(:info).with("Number with files uploaded: 0")
        expect(Rails.logger).to receive(:info).with("== After migration")
        expect(Rails.logger).to receive(:info).with("Number with Typed: 1")
        expect(Rails.logger).to receive(:info).with("Number with Upload: 0")
        expect(Rails.logger).to receive(:info).with("Number with both: 0")
        expect { task.invoke }.to change { statement_of_case.reload.attributes.symbolize_keys }
                                    .from(hash_including(upload: nil, typed: nil))
                                    .to(hash_including(upload: false, typed: true))
      end
    end

    context "when a statement of case exists with text and a file upload" do
      let(:statement_of_case) { create(:statement_of_case, :with_original_file_attached) }

      it "logs the expected output" do
        expect(Rails.logger).to receive(:info).with("== Before migration")
        expect(Rails.logger).to receive(:info).with("Affected applications: 1")
        expect(Rails.logger).to receive(:info).with("Number with text statement: 1")
        expect(Rails.logger).to receive(:info).with("Number with files uploaded: 1")
        expect(Rails.logger).to receive(:info).with("== After migration")
        expect(Rails.logger).to receive(:info).with("Number with Typed: 1")
        expect(Rails.logger).to receive(:info).with("Number with Upload: 1")
        expect(Rails.logger).to receive(:info).with("Number with both: 1")
        expect { task.invoke }.to change { statement_of_case.reload.attributes.symbolize_keys }
                                    .from(hash_including(upload: nil, typed: nil))
                                    .to(hash_including(upload: true, typed: true))
      end
    end

    context "when a statement of case exists with only a file upload" do
      let(:statement_of_case) { create(:statement_of_case, :with_original_file_attached, statement: nil) }

      it "logs the expected output" do
        expect(Rails.logger).to receive(:info).with("== Before migration")
        expect(Rails.logger).to receive(:info).with("Affected applications: 1")
        expect(Rails.logger).to receive(:info).with("Number with text statement: 0")
        expect(Rails.logger).to receive(:info).with("Number with files uploaded: 1")
        expect(Rails.logger).to receive(:info).with("== After migration")
        expect(Rails.logger).to receive(:info).with("Number with Typed: 0")
        expect(Rails.logger).to receive(:info).with("Number with Upload: 1")
        expect(Rails.logger).to receive(:info).with("Number with both: 0")
        expect { task.invoke }.to change { statement_of_case.reload.attributes.symbolize_keys }
                                         .from(hash_including(upload: nil, typed: nil))
                                         .to(hash_including(upload: true, typed: false))
      end
    end
  end
end
