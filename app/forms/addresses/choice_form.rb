module Addresses
  class ChoiceForm < BaseForm
    form_for Applicant

    attr_accessor :correspondence_address_choice

    validates :correspondence_address_choice, presence: true, unless: :draft?
    validates :correspondence_address_choice, inclusion: { in: %w[home residence office] }, allow_blank: true, unless: :draft?

    set_callback :save, :before, :correspondence_address_choice_changed

    def save
      model.no_fixed_residence = nil if correspondence_address_choice.eql?("home")

      if correspondence_address_choice.eql?("office") && !model.correspondence_address_choice.eql?("office")
        model.address = nil
      end

      model.update!(same_correspondence_and_home_address: correspondence_address_choice.eql?("home"))
      super
    end
    alias_method :save!, :save

    def correspondence_address_choice_changed
      @correspondence_address_choice_changed ||= correspondence_address_choice != model.correspondence_address_choice
    end
    alias_method :correspondence_address_choice_changed?, :correspondence_address_choice_changed
  end
end
