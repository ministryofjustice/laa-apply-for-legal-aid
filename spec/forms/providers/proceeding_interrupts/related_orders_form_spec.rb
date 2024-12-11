require "rails_helper"

RSpec.describe Providers::ProceedingInterrupts::RelatedOrdersForm do
  subject(:form) { described_class.new(form_params) }

  let(:proceeding) { create(:proceeding, :pbm05) }
  let(:form_params) { params.merge(model: proceeding) }
  let(:params) do
    {
      related_orders:,
      none_selected:,
    }
  end

  let(:related_orders) { [] }
  let(:none_selected) { "" }

  describe "#valid?" do
    subject(:valid?) { form.valid? }

    context "when a selection has been made" do
      before { form.related_orders = %w[care] }

      it { expect(form).to be_valid }
    end

    context "when multiple selections have been made" do
      before { form.related_orders = %w[care adoption parenting] }

      it { expect(form).to be_valid }
    end

    context "when the user has chosen none_selected" do
      before do
        form.related_orders = []
        form.none_selected = "true"
      end

      it { expect(form).to be_valid }
    end

    context "when the user has chosen nothing" do
      before do
        form.related_orders = [""]
        form.none_selected = ""
      end

      it { expect(form).not_to be_valid }
    end

    context "when the user has chosen none_selected and an order" do
      before do
        form.related_orders = %w[child_assessment]
        form.none_selected = "true"
      end

      it { expect(form).not_to be_valid }
    end
  end

  describe "#save!" do
    subject(:form_save) { form.save! }

    context "when a selection has been made" do
      let(:related_orders) { %w[child_assessment] }

      it "updates the related orders field" do
        form_save
        expect(proceeding.related_orders).to contain_exactly("child_assessment")
      end
    end

    context "when multiple selections have been made" do
      let(:related_orders) { %w[child_assessment child_safety] }

      it "updates the related orders field" do
        form_save
        expect(proceeding.related_orders).to match_array(%w[child_assessment child_safety])
      end
    end

    context "when 'none of the above' and another checkbox are selected" do
      let(:related_orders) { %w[child_assessment] }
      let(:none_selected) { "true" }

      it "returns false" do
        expect(form_save).to be false
      end
    end

    context "when 'none of the above' is selected" do
      let(:none_selected) { "true" }

      it "returns true" do
        expect(form_save).to be true
      end
    end
  end

  describe "save_as_draft" do
    subject(:save_as_draft) { form.save_as_draft }

    context "when the user has chosen nothing" do
      before do
        form.related_orders = []
        form.none_selected = ""
      end

      it { expect(save_as_draft).to be true }
    end
  end
end
