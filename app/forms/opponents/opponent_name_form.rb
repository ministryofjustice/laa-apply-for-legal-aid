module Opponents
  class OpponentNameForm
    include BaseForm

    form_for ApplicationMeritsTask::Opponent

    attr_accessor :full_name

    validates :full_name,
              presence: true,
              unless: :draft?
  end
end
