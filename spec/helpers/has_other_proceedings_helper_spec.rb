require "rails_helper"

RSpec.describe HasOtherProceedingsHelper do
  describe ".show_check_proceeding_warning?" do
    subject(:show_check_proceeding_warning) { helper.show_check_proceeding_warning?(legal_aid_application.proceedings) }

    context "when at least one proceeding is selected which should show a warning" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[se004 se013]) }

      it { is_expected.to be true }
    end

    context "when no proceedings which should show a warning are selected" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 da002]) }

      it { is_expected.to be false }
    end
  end
end
