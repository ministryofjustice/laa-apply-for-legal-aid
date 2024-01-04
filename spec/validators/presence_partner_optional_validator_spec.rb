require "rails_helper"

class DummyPartnerPresenceClass
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :val1, :val2, :val3

  validates :val1, presence: true
  validates :val2, presence_partner_optional: { partner_labels: :partner_check_true? }
  validates :val3, presence_partner_optional: { partner_labels: :partner_check_false? }
  # validates :val4, presence_partner_optional: true

  def partner_check_true?
    true
  end

  def partner_check_false?
    false
  end
end

RSpec.describe PresencePartnerOptionalValidator do
  describe "presence validation" do
    before do
      en = { activemodel: { errors: { models: { dummy_partner_presence_class: { attributes: { val2: { blank: "fake error", blank_with_partner: "fake partner error" } } } } } } }
      I18n.backend.store_translations(:en, en)
    end

    let(:dummy) { DummyPartnerPresenceClass.new }

    it "raises blank or blank_with_partner errors on each invalid field" do
      dummy.val1 = ""
      dummy.val2 = ""
      dummy.val3 = ""
      expect(dummy).not_to be_valid
      expect(dummy.errors.details[:val1].first[:error]).to eq :blank
      expect(dummy.errors.details[:val2].first[:error]).to eq :blank_with_partner
      expect(dummy.errors.details[:val3].first[:error]).to eq :blank
    end

    it "returns _with_partner suffixed labels when prompted" do
      # this requires keys to be present in the activemodel errors locale
      # as they use non standard key names
      dummy.val2 = ""
      expect(dummy).not_to be_valid
      expect(dummy.errors[:val2]).to eq ["fake partner error"]
    end
  end
end
