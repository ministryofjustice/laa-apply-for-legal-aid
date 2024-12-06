require "rails_helper"

RSpec.describe Providers::ProceedingInterrupts::RelatedOrdersForm do
  subject(:form) { described_class.new }

  let(:none_selected) { "" }

  describe "#valid?" do
    subject(:valid?) { form.valid? }

    context "when a selection has been made" do
      before { form.selected_orders = %w[care] }

      it { expect(form).to be_valid }
    end

    context "when multiple selections have been made" do
      before { form.selected_orders = %w[care adoption parenting] }

      it { expect(form).to be_valid }
    end

    context "when the user has chosen none_selected" do
      before do
        form.selected_orders = []
        form.none_selected = "true"
      end

      it { expect(form).to be_valid }
    end

    context "when the user has chosen nothing" do
      before do
        form.selected_orders = []
        form.none_selected = ""
      end

      it { expect(form).not_to be_valid }
    end

    context "when the user has chosen none_selected and an order" do
      before do
        form.selected_orders = %w[child_assessment]
        form.none_selected = "true"
      end

      it { expect(form).not_to be_valid }
    end
  end

  describe "save_as_draft" do
    subject(:save_as_draft) { form.save_as_draft }

    context "when the user has chosen nothing" do
      before do
        form.selected_orders = []
        form.none_selected = ""
      end

      it { expect(save_as_draft).to be true }
    end
  end
end
