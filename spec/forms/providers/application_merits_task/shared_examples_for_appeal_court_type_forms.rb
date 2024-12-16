RSpec.shared_examples "appeal court type selector form" do
  let(:params) do
    {
      model: appeal,
      court_type:,
    }
  end

  describe "#validate" do
    subject(:form) { described_class.new(params) }

    context "when court_type is supreme_court" do
      let(:court_type) { "supreme_court" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when court_type is court_of_appeal" do
      let(:court_type) { "court_of_appeal" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when court_type is blank" do
      let(:court_type) { nil }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:court_type, :blank)
        expect(form.errors.messages[:court_type]).to include("Select which court the appeal will be heard in")
      end
    end

    context "when court_type is invalid value" do
      let(:court_type) { "foobar" }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:court_type, :inclusion, value: "foobar")
        expect(form.errors.messages[:court_type]).to include("Select which court the appeal will be heard in from the available list")
      end
    end
  end

  describe "#save" do
    subject(:save_form) { described_class.new(params).save }

    context "when the form is blank" do
      let(:court_type) { nil }

      it "does not update the record" do
        expect { save_form }.not_to change { appeal.reload.court_type }.from(nil)
      end
    end

    context "when the form is invalid" do
      let(:court_type) { "foobar" }

      it "does not update the record" do
        expect { save_form }.not_to change { appeal.reload.court_type }.from(nil)
      end
    end

    context "when court_type is valid" do
      let(:court_type) { "court_of_appeal" }

      it "updates the record" do
        expect { save_form }.to change { appeal.reload.court_type }.from(nil).to("court_of_appeal")
      end
    end

    context "when value changed" do
      let(:appeal) { create(:appeal, court_type: "court_of_appeal") }
      let(:court_type) { "supreme_court" }

      it "updates the record" do
        expect { save_form }.to change { appeal.reload.court_type }
          .from("court_of_appeal")
          .to("supreme_court")
      end
    end
  end

  describe "#save_as_draft" do
    subject(:form) { described_class.new(params) }

    let(:save_as_draft) { form.save_as_draft }

    context "when the form is blank/invalid" do
      let(:court_type) { nil }

      it "does not validate the form and saves" do
        save_as_draft
        expect(form.errors).to be_empty
        expect { save_as_draft }.not_to change { appeal.reload.court_type }.from(nil)
      end
    end

    context "when the form is not blank" do
      let(:court_type) { "supreme_court" }

      it "updates the record" do
        expect { save_as_draft }.to change { appeal.reload.court_type }.from(nil).to("supreme_court")
      end
    end
  end
end
