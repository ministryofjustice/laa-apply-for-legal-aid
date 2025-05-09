require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::StatementOfCaseUploadForm do
  let(:statement_of_case) { build(:statement_of_case, statement:, typed:, upload:) }

  let(:params) do
    {
      model: statement_of_case,
      original_file:,
    }
  end

  let(:statement) { nil }
  let(:typed) { nil }
  let(:upload) { nil }
  let(:original_file) { nil }

  describe "#validate" do
    subject(:form) { described_class.new(params) }

    context "when the provider has previously set a typed input" do
      let(:statement) { "this was previously recorded" }
      let(:typed) { true }

      context "and requested to upload a file" do
        let(:upload) { true }

        context "and no file has been uploaded via the form or via JS" do
          it "sets the form to invalid" do
            expect(form.valid?).to be false
            expect(form.errors[:original_file]).to contain_exactly "You must choose at least one file"
          end
        end

        context "and has previously uploaded a statement of case via JS" do
          before { create(:attachment, legal_aid_application: statement_of_case.legal_aid_application) }

          it { expect(form.valid?).to be true }
        end
      end
    end
  end
end
