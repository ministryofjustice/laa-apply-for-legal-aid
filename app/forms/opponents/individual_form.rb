module Opponents
  class IndividualForm < BaseForm
    form_for ApplicationMeritsTask::Opponent

    attr_accessor :first_name, :last_name, :legal_aid_application

    validates :first_name, :last_name, presence: true, unless: :draft?

    def save
      return false unless valid?

      model.legal_aid_application = legal_aid_application if legal_aid_application

      if model.opposable
        model.opposable.first_name = first_name
        model.opposable.last_name = last_name
        model.opposable.save!
      else
        model.opposable = ApplicationMeritsTask::Individual.new(first_name:, last_name:)
      end
      model.save!(validate: false)
    end
    alias_method :save!, :save
  end
end
