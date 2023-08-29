require "rails_helper"

RSpec.describe Providers::ProceedingMeritsTask::LinkedChildrenForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) { { linked_children: linked_children_params, model: proceeding } }
  let(:legal_aid_application) { create(:legal_aid_application, :with_involved_children, :with_proceedings, explicit_proceedings: %i[da001 se013], set_lead_proceeding: :da001) }
  let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "SE013") }
  let(:linked_children_params) { nil }

  describe ".value_list" do
    subject(:form) { described_class.new(model: proceeding) }

    let(:expected_array) do
      legal_aid_application.involved_children.map do |child|
        { id: child.id, name: child.full_name, is_checked: false }
      end
    end

    it "loads an array of involved_children from the legal_aid_application" do
      expect(form.value_list).to match_array expected_array
    end
  end

  describe ".valid?" do
    before { form.valid? }

    context "when all values are false" do
      let(:linked_children_params) { ["", "", ""] }

      it { is_expected.to be_invalid }
    end

    context "when all values are true" do
      let(:linked_children_params) do
        legal_aid_application.involved_children.map(&:id)
      end

      it { is_expected.to be_valid }
    end

    context "when one value is true" do
      let(:linked_children_params) do
        legal_aid_application.involved_children.each_with_index.map { |child, index| index.zero? ? child.id : "" }
      end

      it { is_expected.to be_valid }
    end
  end

  describe ".save" do
    subject(:save_form) { form.save }

    let(:linked_children_params) do
      legal_aid_application.involved_children.each_with_index.map { |child, index| index.zero? ? child.id : "" }
    end

    context "when the initial proceeding has no linked_children" do
      it { expect(proceeding.proceeding_linked_children).to be_empty }
      it { expect { save_form }.to change { proceeding.proceeding_linked_children.count }.by(1) }
    end

    context "when a user has previously linked two children" do
      let(:first_child) { legal_aid_application.involved_children.first }
      let(:second_child) { legal_aid_application.involved_children.second }
      let(:third_child) { legal_aid_application.involved_children.third }
      let(:initial_array) { [second_child.id, third_child.id] }
      let(:linked_children_params) { [first_child.id, "", ""] }

      before do
        create(:proceeding_linked_child, proceeding:, involved_child: second_child)
        create(:proceeding_linked_child, proceeding:, involved_child: third_child)
      end

      it { expect { save_form }.to change { proceeding.proceeding_linked_children.count }.by(-1) }
      it { expect(proceeding.proceeding_linked_children.map(&:involved_child_id)).to match_array initial_array }

      context "when an error occurs" do
        let(:linked_children_params) { ["guid-for-non-existent-child", "", ""] }

        it { expect { save_form }.not_to change { proceeding.proceeding_linked_children.count } }

        it "rolls back all changes" do
          expect(save_form).to be false
          expect(proceeding.proceeding_linked_children.reload.map(&:involved_child_id)).to match_array initial_array
        end
      end
    end
  end
end
