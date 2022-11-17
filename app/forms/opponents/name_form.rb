module Opponents
  class NameForm < BaseForm
    form_for ApplicationMeritsTask::Opponent

    attr_accessor :first_name, :last_name

    validates :first_name, :last_name, presence: true, unless: :draft?
  end
end
