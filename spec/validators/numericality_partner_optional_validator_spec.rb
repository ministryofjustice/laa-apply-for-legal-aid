require "rails_helper"

class DummyNumericalityClass
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :val1, :val2, :val3, :val4, :val5

  validates :val1, :val2, numericality_partner_optional: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :val3, numericality_partner_optional: { greater_than_or_equal_to: 0 }
  validates :val4, numericality_partner_optional: { greater_than_or_equal_to: 0, partner_labels: :always_include_partner? }
  validates :val5, numericality_partner_optional: { greater_than_or_equal_to: 0, partner_labels: :always_exclude_partner? }

  def always_include_partner?
    true
  end

  def always_exclude_partner?
    false
  end
end

RSpec.describe NumericalityPartnerOptionalValidator do
  describe "numericality validation" do
    before do
      en = { activemodel: { errors: { models: { dummy_numericality_class: { attributes: { val4: { not_a_number_with_partner: "fake error" }, val5: { not_a_number_with_partner: "fake not a number partner error" } } } } } } }
      I18n.backend.store_translations(:en, en)
    end

    let(:dummy) { DummyNumericalityClass.new }

    it "raises not numeric errors on each invalid field" do
      dummy.val1 = "abc"
      dummy.val2 = ""
      dummy.val3 = nil
      expect(dummy).to be_invalid
      expect(dummy.errors[:val1]).to eq ["is not a number"]
      expect(dummy.errors[:val2]).to be_empty
      expect(dummy.errors[:val3]).to eq ["is not a number"]
      expect(dummy.errors.details[:val4].first[:error]).to eq :not_a_number_with_partner
      expect(dummy.errors[:val4]).to eq ["fake error"]
    end

    it "errors if given negative number" do
      dummy.val1 = Faker::Number.between(from: -9999, to: -1).to_s
      dummy.val2 = Faker::Number.number.to_s
      expect(dummy).to be_invalid
      expect(dummy.errors[:val1]).to eq ["must be greater than or equal to 0"]
      expect(dummy.errors[:val2]).to be_empty
    end

    it "does not clean the number if invalid" do
      dummy.val1 = "-1,234"
      dummy.val2 = "-£1,234.88"
      expect(dummy).to be_invalid
      expect(dummy.val1).to eq "-1,234"
      expect(dummy.val2).to eq "-£1,234.88"
    end

    it "fails if comma is followed by less than 3 digits" do
      dummy.val1 = "1,23.00"
      dummy.val2 = "-£1,23"
      expect(dummy).to be_invalid
      expect(dummy.errors.details[:val1].first[:error]).to eq :not_a_number
      expect(dummy.errors.details[:val2].first[:error]).to eq :not_a_number
      expect(dummy.val1).to eq "1,23.00"
      expect(dummy.val2).to eq "-£1,23"
    end

    it "returns _with_partner suffixed labels when prompted" do
      # this requires keys to be present in the activemodel errors locale
      # as they use non standard key names
      dummy.val4 = "bob"
      dummy.val5 = "jim"
      expect(dummy).to be_invalid
      expect(dummy.errors.details[:val4].first[:error]).to eq :not_a_number_with_partner
      expect(dummy.errors.details[:val5].first[:error]).to eq :not_a_number
      expect(dummy.val4).to eq "bob"
    end
  end
end