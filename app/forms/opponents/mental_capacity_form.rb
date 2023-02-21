module Opponents
  class MentalCapacityForm < BaseForm
    form_for ApplicationMeritsTask::PartiesMentalCapacity

    attr_accessor :understands_terms_of_court_order, :understands_terms_of_court_order_details

    validates :understands_terms_of_court_order, presence: true, unless: :draft?
    validates(
      :understands_terms_of_court_order_details,
      presence: true,
      if: proc { |form| !form.draft? && form.understands_terms_of_court_order.to_s == "false" },
    )

    before_validation :clear_details

  private

    def clear_details
      understands_terms_of_court_order_details.clear if understands_terms_of_court_order.to_s == "true"
    end
  end
end
