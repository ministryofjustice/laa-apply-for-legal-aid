require "rails_helper"

RSpec.describe PolicyDisregardsHelper, type: :helper do
  include ApplicationHelper

  describe "#policy_disregards_hash" do
    let(:result) { policy_disregards_list(policy_disregards) }

    context "with no disregards selected" do
      let(:policy_disregards) { create(:policy_disregards, none_selected: true) }

      it "does not return nil" do
        expect(policy_disregards_list(policy_disregards)).not_to be_nil
      end

      it "returns the correct hash" do
        expect(policy_disregards_list(policy_disregards)).to eq(expected_result_none_selected)
      end
    end

    context "with disregards selected" do
      let(:policy_disregards) { create(:policy_disregards, none_selected: false, england_infected_blood_support: true) }

      it "returns the correct hash" do
        expect(policy_disregards_list(policy_disregards)).to eq(expected_result)
      end
    end

    def expected_result_none_selected
      {
        items: [
          CheckAnswersHelper::ItemStruct.new("England Infected Blood Support Scheme", "No"),
          CheckAnswersHelper::ItemStruct.new("Vaccine Damage Payments Scheme", "No"),
          CheckAnswersHelper::ItemStruct.new("Variant Creutzfeldt-Jakob disease (vCJD) Trust", "No"),
          CheckAnswersHelper::ItemStruct.new("Criminal Injuries Compensation Scheme", "No"),
          CheckAnswersHelper::ItemStruct.new("National Emergencies Trust (NET)", "No"),
          CheckAnswersHelper::ItemStruct.new("We Love Manchester Emergency Fund", "No"),
          CheckAnswersHelper::ItemStruct.new("The London Emergencies Trust", "No"),
        ],
      }
    end

    def expected_result
      {
        items: [CheckAnswersHelper::ItemStruct.new("England Infected Blood Support Scheme", true)] + expected_result_none_selected[:items][1..],
      }
    end
  end
end
