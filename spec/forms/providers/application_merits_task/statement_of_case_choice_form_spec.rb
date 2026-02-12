require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::StatementOfCaseChoiceForm do
  let(:statement_of_case) { build(:statement_of_case, statement:, typed:, upload:) }

  let(:params) do
    {
      model: statement_of_case,
      statement:,
      typed:,
      upload:,
    }
  end

  let(:statement) { nil }
  let(:typed) { nil }
  let(:upload) { nil }

  describe "#validate" do
    subject(:form) { described_class.new(params) }

    context "when both upload and typed are blank" do
      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:upload, :blank)
        expect(form.errors.messages[:upload]).to include("Select how you will provide the statement of case")
      end
    end

    context "when typed is chosen but no statement provided" do
      let(:typed) { ["", "true"] }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:statement, :blank)
        expect(form.errors.messages[:statement]).to include("Provide a typed statement of case")
      end
    end
  end

  describe "#save" do
    subject(:save_form) { form.save }

    let(:form) { described_class.new(params) }

    context "when the form is invalid" do
      let(:typed) { "true" }

      it "does not create a record" do
        expect { save_form }.not_to change(ApplicationMeritsTask::StatementOfCase, :count).from(0)
      end
    end

    context "when the provider chose both options" do
      let(:statement_of_case) { build(:statement_of_case, statement: nil, typed: nil, upload: nil) }
      let(:upload) { ["", "true"] }
      let(:typed) { ["", "true"] }
      let(:statement) { "Text entry" }

      it "creates a record" do
        expect { save_form }.to change(ApplicationMeritsTask::StatementOfCase, :count).from(0).to(1)
      end
    end
  end
end
