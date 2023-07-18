module Opponents
  class IndividualForm < BaseForm
    form_for ApplicationMeritsTask::Opponent

    attr_accessor :first_name, :last_name, :legal_aid_application

    validates :first_name, :last_name, presence: true, unless: :draft?

    def save
      return false unless valid?

      # return true if assignable_attributes.empty?

      model.legal_aid_application = legal_aid_application if legal_aid_application
      model.opposable = ApplicationMeritsTask::Individual.new(first_name:, last_name:)
      model.save!(validate: false)
    end
    alias_method :save!, :save
  end
end
