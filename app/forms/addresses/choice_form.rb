module Addresses
  class ChoiceForm < BaseForm
    form_for Applicant

    attr_accessor :correspondence_address_choice

    validates :correspondence_address_choice, presence: true, unless: :draft?
    validates :correspondence_address_choice, inclusion: { in: %w[home residence office] }, allow_blank: true, unless: :draft?

    def save
      model.update!(same_correspondence_and_home_address: correspondence_address_choice.eql?("home"))
      super
    end
    alias_method :save!, :save
  end
end
