require "rails_helper"

RSpec.describe Partners::DetailsForm, type: :form do
  subject(:partner_form) { described_class.new(params) }

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:params) do
    {
      first_name:,
      last_name: "Snow",
      date_of_birth_3i: date_of_birth&.day&.to_s,
      date_of_birth_2i: date_of_birth&.month&.to_s,
      date_of_birth_1i: date_of_birth&.year&.to_s,
      has_national_insurance_number: "true",
      national_insurance_number:,
    }.merge(model: legal_aid_application.build_partner)
  end
  let(:first_name) { "John" }
  let(:date_of_birth) { Time.zone.today - 18.years }
  let(:national_insurance_number) { "AB123456C" }

  describe "#save" do
    subject(:partner) { partner_form.save }

    it "creates a new partner linked to the legal_aid_application with the expected attributes" do
      expect { partner_form.save }.to change(Partner, :count).by(1)
      expect(legal_aid_application.reload.partner).to have_attributes(
        first_name: "John",
        last_name: "Snow",
        national_insurance_number: "AB123456C",
      )
    end

    context "with first name missing" do
      let(:first_name) { "" }

      it "does not persist model" do
        expect { partner_form.save }.not_to change(Partner, :count)
      end

      it "errors to be present" do
        partner_form.save!
        expect(partner_form.errors[:first_name]).to contain_exactly("Enter first name")
      end
    end

    context "with an invalid NINO" do
      let(:national_insurance_number) { "foobar" }

      it "does not persist model" do
        expect { partner_form.save }.not_to change(Partner, :count)
      end

      it "errors to be present" do
        partner_form.save!
        expect(partner_form.errors[:national_insurance_number]).to contain_exactly("Enter a valid National Insurance number")
      end
    end

    context "with test national insurance numbers" do
      let(:test_nino) { "JS130161E" }
      let(:invalid_nino) { "QQ12AS23RR" }
      let(:valid_nino) { "JA123456D" }

      before do
        allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return(in_test_mode)
      end

      context "with normal validation" do
        let(:in_test_mode) { "false" }

        it "test nino is invalid" do
          partner_form.national_insurance_number = test_nino
          expect(partner_form).not_to be_valid
        end

        it "invalid NINO is still invalid" do
          partner_form.national_insurance_number = invalid_nino
          expect(partner_form).not_to be_valid
        end

        it "valid NINO is still valid" do
          partner_form.national_insurance_number = valid_nino
          expect(partner_form).to be_valid
        end
      end

      context "with test level validation" do
        let(:in_test_mode) { "true" }

        it "test NINO is valid" do
          partner_form.national_insurance_number = test_nino
          expect(partner_form).to be_valid
        end

        it "invalid NINO is still invalid" do
          partner_form.national_insurance_number = invalid_nino
          expect(partner_form).not_to be_valid
        end

        it "valid NINO is still valid" do
          partner_form.national_insurance_number = valid_nino
          expect(partner_form).to be_valid
        end
      end
    end

    context "with dob in the future" do
      let(:date_of_birth) { 3.days.from_now }

      it "does not persist model" do
        expect { partner_form.save }.not_to change(Partner, :count)
      end

      it "errors to be present" do
        partner_form.save!
        expect(partner_form.errors[:date_of_birth]).to contain_exactly("Date of birth must be in the past")
      end
    end

    context "with a two digit year greater than current year" do
      let(:current_year) { Time.current.strftime("%y").to_i }
      let(:date_of_birth) { Date.new(current_year + 1, 1, 1) }

      it "sets the date of birth to be 19xx" do
        partner_form.save!
        expect(legal_aid_application.reload.partner).to have_attributes(date_of_birth: Date.new("19#{current_year + 1}".to_i, 1, 1))
      end
    end

    context "with a two digit year less than current year" do
      let(:current_year) { Time.current.strftime("%y").to_i }
      let(:date_of_birth) { Date.new(current_year - 1, 1, 1) }

      it "sets the date of birth to be 19xx" do
        partner_form.save!
        expect(legal_aid_application.reload.partner).to have_attributes(date_of_birth: Date.new("20#{current_year - 1}".to_i, 1, 1))
      end
    end

    context "with invalid dob elements" do
      let(:params) do
        {
          first_name:,
          last_name: "Snow",
          date_of_birth_3i: "10",
          date_of_birth_2i: "21",
          date_of_birth_1i: "44",
          has_national_insurance_number: "true",
          national_insurance_number:,
        }.merge(model: legal_aid_application.build_partner)
      end

      it "is not valid" do
        expect { partner_form.save }.not_to change(Partner, :count)
      end

      it "sets errors" do
        partner_form.save!
        expect(partner_form.errors[:date_of_birth]).to contain_exactly("Enter a valid date of birth")
      end
    end
  end

  describe "save_as_draft" do
    subject(:partner_as_draft) { partner_form.save_as_draft }

    it "creates a new partner linked to the legal_aid_application with the expected attributes" do
      expect { partner_form.save_as_draft }.to change(Partner, :count).by(1)
      expect(legal_aid_application.reload.partner).to have_attributes(
        first_name: "John",
        last_name: "Snow",
        national_insurance_number: "AB123456C",
      )
    end

    context "with empty input" do
      let(:params) do
        {
          first_name: "",
          last_name: "",
          date_of_birth: "",
          has_national_insurance_number: "",
          national_insurance_number:,
        }.merge(model: legal_aid_application.build_partner)
      end

      it "is valid" do
        partner_as_draft
        expect(partner_form).to be_valid
      end

      it "saves to the database" do
        expect { partner_as_draft }.to change(Partner, :count)
      end
    end

    context "with mostly empty input" do
      let(:first_name) { Faker::Name.first_name }
      let(:params) do
        {
          first_name:,
          last_name: "",
          date_of_birth: "",
          has_national_insurance_number: "",
          national_insurance_number:,
        }.merge(model: legal_aid_application.build_partner)
      end

      it "saves the entered attribute" do
        partner_as_draft
        expect(legal_aid_application.reload.partner.first_name).to eq(first_name)
      end

      it "does not save anything to null attributes" do
        partner_as_draft
        expect(legal_aid_application.reload.partner.last_name).to be_nil
      end
    end

    context "with an invalid entry input" do
      let(:first_name) { Faker::Name.first_name }
      let(:invalid_nino) { "invalid" }
      let(:params) do
        {
          first_name:,
          last_name: "",
          date_of_birth: "",
          has_national_insurance_number: "true",
          national_insurance_number: invalid_nino,
        }.merge(model: legal_aid_application.build_partner)
      end

      it "does not save to the database" do
        expect { partner_as_draft }.not_to change(Partner, :count)
      end

      it "is invalid" do
        partner_as_draft
        expect(partner_form).not_to be_valid
      end

      it "preserves the input" do
        partner_as_draft
        expect(partner_form.first_name).to eq(first_name)
        expect(partner_form.national_insurance_number).to eq(invalid_nino)
      end
    end

    context "with incomplete dob elements" do
      # Note peculiar behaviour `Date.parse '4-10-'` generates a valid date. Go figure!
      # So need to test for that.
      let(:params) do
        {
          first_name:,
          last_name: "Snow",
          date_of_birth_2i: "10",
          date_of_birth_3i: "4",
          has_national_insurance_number: "true",
          national_insurance_number:,
        }.merge(model: legal_aid_application.build_partner)
      end

      before { partner_as_draft }

      it "generates an error" do
        expect(partner_form).not_to be_valid
      end
    end
  end
end
