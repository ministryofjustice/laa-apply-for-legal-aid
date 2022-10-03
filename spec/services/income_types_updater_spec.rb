require "rails_helper"

RSpec.fdescribe IncomeTypesUpdater do
  let(:instance) { described_class.new(params) }

  describe "#save" do
    subject(:save) { instance.save }

    let(:legal_aid_application) { create(:legal_aid_application) }


    context "with valid params" do
      let(:params) do
        {
          legal_aid_application:
          {
            transaction_type_ids:,
          },
        }
      end
    end

    context "with invalid params" do
      #<ActionController::Parameters {"legal_aid_application"=>{"transaction_type_ids"=>["5d80b726-747c-4d6e-ad9d-185d4cadbc3a", "dc248223-e595-4148-b0aa-1394692f3a60", "e9ae9287-57d3-412b-8419-e239d4dab324"]}, "locale"=>"en", "controller"=>"providers/means/identify_types_of_incomes", "action"=>"update", "legal_aid_application_id"=>"f44d5246-63fe-47b6-9967-87cfd96d1b37"} permitted: false>
      #<ActionController::Parameters {"legal_aid_application"=>{"none_selected"=>"true"}, "locale"=>"en", "controller"=>"providers/means/identify_types_of_incomes", "action"=>"update", "legal_aid_application_id"=>"4eb38c64-c2eb-44a8-ac14-cd3a000d330e"} permitted: false>
      let(:params) do
        ActionController::Parameters.new(
          {
            legal_aid_application: {
              legal_aid_application_id: legal_aid_application.id,
              none_selected: "true",
            },
          }
        )
      end

      it { expect(save).to change(legal_aid_application.legal_aid_application_transaction_types, :count).by(1) }
    end
  end
end
