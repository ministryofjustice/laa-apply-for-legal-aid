module Addresses
  class AddressLookupForm
    include BaseForm

    form_for Address

    attr_accessor :applicant_id, :postcode

    before_validation :normalise_postcode

    validates :postcode, presence: true, unless: :draft?
    validates :postcode, format: { with: POSTCODE_REGEXP, if: proc { |a| a.postcode.present? } }

    def save_as_draft
      @draft = true
      save
    end

    private

    def normalise_postcode
      return unless postcode.present?

      postcode.delete!(' ')
      postcode.upcase!
    end
  end
end
