require "rails_helper"

RSpec.describe CapitalDisregardHelper do
  let(:legal_aid_application) { create(:legal_aid_application) }

  let(:create_mandatory_disregards) do
    create(
      :capital_disregard,
      legal_aid_application:,
      mandatory: true,
      name: "budgeting_advances",
      amount: 1001,
      date_received: Date.new(2024, 8, 8),
      account_name: "Halifax",
    )

    create(
      :capital_disregard,
      legal_aid_application:,
      mandatory: true,
      name: "government_cost_of_living",
      amount: 1001,
      date_received: Date.new(2024, 8, 8),
      account_name: "Santander",
    )
  end

  let(:create_discretionary_disregards) do
    create(
      :capital_disregard,
      legal_aid_application:,
      mandatory: false,
      name: "compensation_for_personal_harm",
      payment_reason: "I got hurt badly",
      amount: 1001,
      date_received: Date.new(2024, 8, 25),
      account_name: "Halifax",
    )

    create(
      :capital_disregard,
      legal_aid_application:,
      mandatory: false,
      name: "grenfell_tower_fire_victims",
      amount: 1001,
      date_received: Date.new(2024, 8, 25),
      account_name: "Santander",
    )
  end

  describe "#mandatory_capital_disregards_list" do
    subject { mandatory_capital_disregards_list(legal_aid_application) }

    context "without mandatory disregards" do
      it { is_expected.to eq "" }
    end

    context "with mandatory disregards" do
      before { create_mandatory_disregards }

      it { is_expected.to eq("Budgeting Advances<br>Government cost of living payment") }
    end
  end

  describe "#mandatory_capital_disregards_detailed_list" do
    subject { mandatory_capital_disregards_detailed_list(legal_aid_application) }

    context "without mandatory disregards" do
      it { is_expected.to eq "" }
    end

    context "with mandatory disregards" do
      before { create_mandatory_disregards }

      it { is_expected.to eq("Budgeting Advances<br>£1,001 on 8 August 2024<br>Held in Halifax<br><br>Government cost of living payment<br>£1,001 on 8 August 2024<br>Held in Santander") }
    end
  end

  describe "#discretionary_capital_disregards_list" do
    subject { discretionary_capital_disregards_list(legal_aid_application) }

    context "without discretionary disregards" do
      it { is_expected.to eq "" }
    end

    context "with discretionary disregards" do
      before { create_discretionary_disregards }

      it { is_expected.to eq("Compensation, damages or ex-gratia payments for personal harm<br>Grenfell Tower fire victims payment") }
    end

    describe "#discretionary_capital_disregards_detailed_list" do
      subject { discretionary_capital_disregards_detailed_list(legal_aid_application) }

      context "without discretionary disregards" do
        it { is_expected.to eq "" }
      end

      context "with discretionary disregards" do
        before { create_discretionary_disregards }

        it { is_expected.to eq("Compensation, damages or ex-gratia payments for personal harm<br>For: I got hurt badly<br>£1,001 on 25 August 2024<br>Held in Halifax<br><br>Grenfell Tower fire victims payment<br>£1,001 on 25 August 2024<br>Held in Santander") }
      end
    end
  end

  describe "#amount_and_date_received" do
    subject { amount_and_date_received(capital_disregard) }

    let(:capital_disregard) do
      build(
        :capital_disregard,
        legal_aid_application:,
        amount: 1001.10,
        date_received:,
      )
    end

    context "with single digit day" do
      let(:date_received) { Date.new(2024, 8, 8) }

      it { is_expected.to eq "£1,001.10 on 8 August 2024" }
    end

    context "with double digit day" do
      let(:date_received) { Date.new(2024, 8, 25) }

      it { is_expected.to eq "£1,001.10 on 25 August 2024" }
    end
  end
end
