require "rails_helper"

RSpec.describe Applicants::BasicDetailsForm, type: :form do
  subject { described_class.new(params) }

  let(:params) { attributes.slice(*attr_list).merge(model: legal_aid_application.build_applicant) }
  let(:attr_list) do
    %i[
      first_name
      last_name
      date_of_birth
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
      expect { subject.save }.to change(Applicant, :count).by(1)
    end

    it "saves attributes to the new applicant" do
      subject.save
      attr_list.each do |attribute|
        expect(applicant.send(attribute)).to eq(attributes[attribute]), "Should match #{attribute}"
      end
    end

    it "saved application belongs to legal_aid_application" do
      subject.save
      expect(applicant).to eq(legal_aid_application.reload.applicant)
    end

    context "with first name missing" do
      before { attr_list.delete(:first_name) }

      it "does not persist model" do
        expect { subject.save }.not_to change(Applicant, :count)
      end

      it "errors to be present" do
        subject.save
        expect(subject.errors[:first_name]).to match_array(["Enter first name"])
      end
    end

    context "with an invalid date" do
      let(:attributes) { attributes_for(:applicant).merge(date_of_birth: "invalid-date") }

      it "does not persist model" do
        expect { subject.save }.not_to change(Applicant, :count)
      end

      it "errors to be present" do
        subject.save
        expect(subject.errors[:date_of_birth]).to match_array(["Enter a valid date of birth"])
      end
    end

    context "with dob in the future" do
      let(:attributes) { attributes_for(:applicant).merge(date_of_birth: 3.days.from_now) }

      it "does not persist model" do
        expect { subject.save }.not_to change(Applicant, :count)
      end

      it "errors to be present" do
        subject.save
        expect(subject.errors[:date_of_birth]).to match_array(["Enter a valid date of birth"])
      end
    end

    context "with dob elements" do
      let(:params) do
        {
          first_name: attributes[:first_name],
          last_name: attributes[:last_name],
          date_of_birth_1i: attributes[:date_of_birth].year.to_s,
          date_of_birth_2i: attributes[:date_of_birth].month.to_s,
          date_of_birth_3i: attributes[:date_of_birth].day.to_s,
          model: applicant,
        }
      end

      it "is valid" do
        expect { subject.save }.to change(Applicant, :count)
      end

      it "saves the date" do
        subject.save
        expect(Applicant.last.date_of_birth).to eq(attributes[:date_of_birth])
      end
    end

    context "with invalid dob elements" do
      let(:params) do
        {
          first_name: attributes[:first_name],
          last_name: attributes[:last_name],
          date_of_birth_1i: "10",
          date_of_birth_2i: "21",
          date_of_birth_3i: "44",
          model: applicant,
        }
      end

      it "is not valid" do
        expect { subject.save }.not_to change(Applicant, :count)
      end

      it "sets errors" do
        subject.save
        expect(subject.errors[:date_of_birth]).to match_array(["Enter a valid date of birth"])
      end
    end
  end

  describe "save_as_draft" do
    let(:applicant) { Applicant.last }

    it "creates a new applicant" do
      expect { subject.save_as_draft }.to change(Applicant, :count).by(1)
    end

    it "saves attributes to the new applicant" do
      subject.save_as_draft
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
        }
      end

      it "will not save to the database" do
        expect { subject.save_as_draft }.not_to change(Applicant, :count)
      end

      it "will be invalid" do
        subject.save_as_draft
        expect(subject).to be_invalid
      end

      it "will preserve the input" do
        subject.save_as_draft
        expect(subject.first_name).to eq("Fred")
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
        }
      end

      it "will not save to the database" do
        expect { subject.save_as_draft }.not_to change(Applicant, :count)
      end

      it "will be invalid" do
        subject.save_as_draft
        expect(subject).to be_invalid
      end

      it "will preserve the valid input" do
        subject.save_as_draft
        expect(subject.date_of_birth).to eq(Date.new(1999, 12, 31))
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
        }
      end

      it "will save to the database" do
        expect { subject.save_as_draft }.to change(Applicant, :count)
      end

      it "will be invalid" do
        subject.save_as_draft
        expect(subject).to be_valid
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
        }
      end

      it "will save to the database" do
        expect { subject.save_as_draft }.to change(Applicant, :count)
      end

      it "will be valid" do
        subject.save_as_draft
        expect(subject).to be_valid
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
          model: applicant,
        }
      end

      before { subject.save_as_draft }

      it "generates an error" do
        expect(subject).to be_invalid
      end
    end
  end

  describe "#model" do
    it "returns a new applicant" do
      expect(subject.model).to be_a(Applicant)
      expect(subject.model).not_to be_persisted
    end

    context "with an existing applicant passed in" do
      let(:applicant) { create(:applicant) }
      let(:params) { attributes.slice(*attr_list).merge(model: applicant) }

      it "returns the applicant" do
        expect(subject.model).to eq(applicant)
      end
    end

    context "with no attributes but populated model" do
      let(:applicant) { create(:applicant) }
      let(:params) { { model: applicant } }

      it "populates attributes from model" do
        expect(subject.first_name).to eq(applicant.first_name)
        expect(subject.last_name).to eq(applicant.last_name)
      end

      it "populates dob fields from model" do
        expect(subject.date_of_birth_1i).to eq(applicant.date_of_birth.year)
        expect(subject.date_of_birth_2i).to eq(applicant.date_of_birth.month)
        expect(subject.date_of_birth_3i).to eq(applicant.date_of_birth.day)
      end
    end
  end

  describe "attributes" do
    it "matches passed in attributes" do
      expect(subject.first_name).to be_present
      attr_list.each do |attribute|
        expect(subject.send(attribute)).to eq(attributes[attribute]), "Should match #{attribute}"
      end
    end
  end
end
