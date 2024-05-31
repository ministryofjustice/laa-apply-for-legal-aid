module Addresses
  class ChoiceForm < BaseForm
    form_for Applicant

    attr_accessor :correspondence_address_choice

    validates :correspondence_address_choice, presence: true, unless: :draft?
    validates :correspondence_address_choice, inclusion: { in: %w[home residence office] }, allow_blank: true, unless: :draft?
  end
end
