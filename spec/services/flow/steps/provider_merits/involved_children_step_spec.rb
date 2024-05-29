require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::InvolvedChildrenStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application, params) }

    let(:partial_record) { create(:involved_child, legal_aid_application:) }
    let(:id) { "new" }
    let(:params) do
      { _method: "patch",
        application_merits_task_involved_child: { "full_name" => partial_record&.full_name, "date_of_birth(3i)" => "", "date_of_birth(2i)" => "", "date_of_birth(1i)" => "" },
        draft_button: "Save and come back later",
        locale: "en",
        id: }
    end

    context "when involved_child_id is new" do
      context "with partial record" do
        it { is_expected.to eq providers_legal_aid_application_involved_child_path(legal_aid_application, partial_record) }
      end

      context "without partial record" do
        let(:partial_record) { nil }

        it { is_expected.to eq new_providers_legal_aid_application_involved_child_path(legal_aid_application) }
      end
    end

    context "when involved_child_id is an id" do
      let(:id) { partial_record.id }

      it { is_expected.to eq providers_legal_aid_application_involved_child_path(legal_aid_application, partial_record.id) }
    end

    context "when involved_child_id is false" do
      let(:params) { "foo" }

      it { is_expected.to eq new_providers_legal_aid_application_involved_child_path(legal_aid_application) }
    end
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :has_other_involved_children }
  end
end
