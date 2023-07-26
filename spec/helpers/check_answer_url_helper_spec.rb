require "rails_helper"

RSpec.describe CheckAnswerUrlHelper do
  let(:application) { create(:legal_aid_application) }

  describe "#check_answer_url_for" do
    context "when a provider" do
      it "returns the path" do
        url = check_answer_url_for(:providers, :own_homes, application)
        expect(url).to eq "/providers/applications/#{application.id}/means/own_home?locale=en"
      end

      context "when params are provided" do
        let(:params) { { transaction_type: "benefits" } }

        it "returns the correct path" do
          url = check_answer_url_for(:providers, :incoming_transactions, application, params)
          expect(url).to eq "/providers/applications/#{application.id}/incoming_transactions/benefits?locale=en"
        end
      end
    end

    context "when a citizen" do
      context "with default locale" do
        it "returns the path with en locale" do
          url = check_answer_url_for(:citizens, :consents)
          expect(url).to eq "/citizens/consent?locale=en"
        end
      end

      context "with Welsh locale" do
        around do |example|
          I18n.with_locale(:cy) { example.run }
        end

        it "returns the path with cy locale" do
          url = check_answer_url_for(:citizens, :consents)
          expect(url).to eq "/citizens/consent?locale=cy"
        end
      end
    end
  end
end
