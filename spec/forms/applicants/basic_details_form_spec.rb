require "rails_helper"

RSpec.describe Applicants::BasicDetailsForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) { attributes.slice(*attr_list).merge(model: legal_aid_application.build_applicant, changed_last_name: "false") }
  let(:attr_list) do
    %i[
      first_name
      last_name
      date_of_birth
      last_name_at_birth
    ]
  end
  let(:legal_aid_application_id) { legal_aid_application.id }
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:attributes) { attributes_for(:applicant) }

  describe ".model_name" do
    it 'is "Applicant"' do
      expect(described_class.model_name).to eq("Applicant")
    end
  end

  describe "#save" do
    let(:applicant) { Applicant.last }

    it "creates a new applicant" do
      expect { form.save }.to change(Applicant, :count).by(1)
    end

    it "saves attributes to the new applicant" do
      form.save!
      attr_list.each do |attribute|
        expect(applicant.send(attribute)).to eq(attributes[attribute]), "Should match #{attribute}"
      end
    end

    it "saved application belongs to legal_aid_application" do
      form.save!
      expect(applicant).to eq(legal_aid_application.reload.applicant)
    end

    context "with first name missing" do
      before { attr_list.delete(:first_name) }

      it "does not persist model" do
        expect { form.save }.not_to change(Applicant, :count)
      end

      it "errors to be present" do
        form.save!
        expect(form.errors[:first_name]).to contain_exactly("Enter first name")
      end
    end

    context "with an invalid date_of_birth string" do
      let(:attributes) { attributes_for(:applicant).merge(date_of_birth: "invalid-date") }

      it "does not persist model" do
        expect { form.save }.not_to change(Applicant, :count)
      end

      it "adds expected error" do
        form.save!
        expect(form.errors[:date_of_birth]).to contain_exactly("Enter a valid date of birth")
      end
    end

    context "with date_of_birth in the future" do
      let(:attributes) { attributes_for(:applicant).merge(date_of_birth: Date.tomorrow) }

      it "does not persist model" do
        expect { form.save }.not_to change(Applicant, :count)
      end

      it "adds expected error" do
        form.save!
        expect(form.errors[:date_of_birth]).to contain_exactly("Date of birth must be in the past")
      end
    end

    context "with date_of_birth earlier than ealiest allowed date" do
      let(:attributes) { attributes_for(:applicant).merge(date_of_birth: "1899-12-31".to_date) }

      it "does not persist model" do
        expect { form.save }.not_to change(Applicant, :count)
      end

      it "adds expected error" do
        form.save!
        expect(form.errors[:date_of_birth]).to contain_exactly("Enter a valid date of birth")
      end
    end

    context "with date_of_birth elements" do
      let(:params) do
        {
          first_name: attributes[:first_name],
          last_name: attributes[:last_name],
          date_of_birth_1i: attributes[:date_of_birth].year.to_s,
          date_of_birth_2i: attributes[:date_of_birth].month.to_s,
          date_of_birth_3i: attributes[:date_of_birth].day.to_s,
          changed_last_name: "false",
          model: applicant,
        }
      end

      it "creates applicant succesfully" do
        expect { form.save }.to change(Applicant, :count)
      end

      it "saves the date" do
        form.save!
        expect(Applicant.last.date_of_birth).to eq(attributes[:date_of_birth])
      end
    end

    context "with spaces in dates" do
      let(:params) do
        {
          first_name: attributes[:first_name],
          last_name: attributes[:last_name],
          date_of_birth_1i: "1990  ",
          date_of_birth_2i: "3 ",
          date_of_birth_3i: " 2",
          changed_last_name: "false",
          model: applicant,
        }
      end

      it "creates applicant successfully" do
        expect { form.save }.to change(Applicant, :count)
      end

      it "saves the date" do
        form.save!
        expect(Applicant.last.date_of_birth).to eq(Date.new(1990, 3, 2))
      end
    end

    context "with invalid date_of_birth elements" do
      let(:params) do
        {
          first_name: attributes[:first_name],
          last_name: attributes[:last_name],
          date_of_birth_1i: "10",
          date_of_birth_2i: "21",
          date_of_birth_3i: "44",
          changed_last_name: "false",
          model: applicant,
        }
      end

      it "does not persist model" do
        expect { form.save }.not_to change(Applicant, :count)
      end

      it "adds expected error" do
        form.save!
        expect(form.errors[:date_of_birth]).to contain_exactly("Enter a valid date of birth")
      end
    end
  end

  describe "save_as_draft" do
    let(:attr_list) do
      %i[
        first_name
        last_name
        date_of_birth
        last_name_at_birth
      ]
    end

    let(:applicant) { Applicant.last }

    it "creates a new applicant" do
      expect { form.save_as_draft }.to change(Applicant, :count).by(1)
    end

    it "saves attributes to the new applicant" do
      form.save_as_draft
      attr_list.each do |attribute|
        expect(applicant.send(attribute)).to eq(attributes[attribute]), "Should match #{attribute}"
      end
    end

    context "with an invalid date_of_birth entry input" do
      let(:params) do
        {
          first_name: "Fred",
          last_name: "Bloggs",
          date_of_birth_1i: "0001",
          date_of_birth_2i: "13",
          date_of_birth_3i: "32",
          changed_last_name: "false",
        }
      end

      it "does not save to the database" do
        expect { form.save_as_draft }.not_to change(Applicant, :count)
      end

      it "is invalid" do
        form.save_as_draft
        expect(form).not_to be_valid
      end

      it "preserves the input" do
        form.save_as_draft
        expect(form.first_name).to eq("Fred")
      end
    end

    context "with no first name or last name" do
      let(:params) do
        {
          first_name: "",
          last_name: "",
          date_of_birth_1i: "1999",
          date_of_birth_2i: "12",
          date_of_birth_3i: "31",
          changed_last_name: "false",
        }
      end

      it "does not save to the database" do
        expect { form.save_as_draft }.not_to change(Applicant, :count)
      end

      it "is invalid" do
        form.save_as_draft
        expect(form).not_to be_valid
      end

      it "preserves the valid input" do
        form.save_as_draft
        expect(form.date_of_birth).to eq(Date.new(1999, 12, 31))
      end
    end

    context "with no first name but with last name" do
      let(:params) do
        {
          first_name: "",
          last_name: "Bloggs",
          date_of_birth_1i: "1999",
          date_of_birth_2i: "12",
          date_of_birth_3i: "31",
          changed_last_name: "false",
        }
      end

      it "saves to the database" do
        expect { form.save_as_draft }.to change(Applicant, :count)
      end

      it "is invalid" do
        form.save_as_draft
        expect(form).to be_valid
      end
    end

    context "with last name but no first name" do
      let(:params) do
        {
          first_name: "Fred",
          last_name: "",
          date_of_birth_1i: "1999",
          date_of_birth_2i: "12",
          date_of_birth_3i: "31",
          changed_last_name: "false",
        }
      end

      it "saves to the database" do
        expect { form.save_as_draft }.to change(Applicant, :count)
      end

      it "is valid" do
        form.save_as_draft
        expect(form).to be_valid
      end
    end

    context "with incomplete dob elements" do
      # Note peculiar behaviour `Date.parse '4-10-'` generates a valid date. Go figure!
      # So need to test for that.
      let(:params) do
        {
          first_name: attributes[:first_name],
          last_name: attributes[:last_name],
          date_of_birth_2i: "10",
          date_of_birth_3i: "4",
          changed_last_name: "false",
          model: applicant,
        }
      end

      before { form.save_as_draft }

      it "generates an error" do
        expect(form).not_to be_valid
      end
    end
  end

  context "with changed last name" do
    let(:params) do
      {
        first_name: "Fred",
        last_name: "Bloggs",
        date_of_birth_1i: "1999",
        date_of_birth_2i: "12",
        date_of_birth_3i: "31",
        changed_last_name: "true",
        last_name_at_birth: "Smith",
      }
    end

    it "is valid" do
      expect(form).to be_valid
    end

    it "saves to the database" do
      expect { form.save }.to change(Applicant, :count)
    end
  end

  context "with changed_last_name nil" do
    let(:params) do
      {
        first_name: "Fred",
        last_name: "Bloggs",
        date_of_birth_1i: "1999",
        date_of_birth_2i: "12",
        date_of_birth_3i: "31",
        changed_last_name: nil,
        last_name_at_birth: "",
      }
    end

    it "adds expected error" do
      form.save!
      expect(form.errors[:changed_last_name]).to contain_exactly("Select yes if your client has ever changed their last name")
    end
  end

  context "with changed_last_name but no last_name_at_birth" do
    let(:params) do
      {
        first_name: "Fred",
        last_name: "Bloggs",
        date_of_birth_1i: "1999",
        date_of_birth_2i: "12",
        date_of_birth_3i: "31",
        changed_last_name: "true",
        last_name_at_birth: "",
      }
    end

    it "adds expected error" do
      form.save!
      expect(form.errors[:last_name_at_birth]).to contain_exactly("Enter your client's last name at birth")
    end
  end

  context "when saving as draft with changed_last_name but no last_name_at_birth" do
    let(:params) do
      {
        first_name: "Fred",
        last_name: "Bloggs",
        date_of_birth_1i: "1999",
        date_of_birth_2i: "12",
        date_of_birth_3i: "31",
        changed_last_name: "true",
        last_name_at_birth: "",
      }
    end

    it "saves to the database" do
      expect { form.save_as_draft }.to change(Applicant, :count)
    end

    it "is valid" do
      form.save_as_draft
      expect(form).to be_valid
    end
  end

  describe "#model" do
    it "returns a new applicant" do
      expect(form.model).to be_a(Applicant)
      expect(form.model).not_to be_persisted
    end

    context "with an existing applicant passed in" do
      let(:applicant) { create(:applicant) }
      let(:params) { attributes.slice(*attr_list).merge(model: applicant) }

      it "returns the applicant" do
        expect(form.model).to eq(applicant)
      end
    end

    context "with no attributes but populated model" do
      let(:applicant) { create(:applicant) }
      let(:params) { { model: applicant } }

      it "populates attributes from model" do
        expect(form.first_name).to eq(applicant.first_name)
        expect(form.last_name).to eq(applicant.last_name)
      end

      it "populates dob fields from model" do
        expect(form.date_of_birth_1i).to eq(applicant.date_of_birth.year)
        expect(form.date_of_birth_2i).to eq(applicant.date_of_birth.month)
        expect(form.date_of_birth_3i).to eq(applicant.date_of_birth.day)
      end
    end
  end

  describe "attributes" do
    it "matches passed in attributes" do
      expect(form.first_name).to be_present
      attr_list.each do |attribute|
        expect(form.send(attribute)).to eq(attributes[attribute]), "Should match #{attribute}"
      end
    end
  end
end
