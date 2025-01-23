module Providers
  module ApplicationMeritsTask
    class MatterOpposedForm < BaseForm
      form_for ::ApplicationMeritsTask::MatterOpposed

      attr_accessor :matter_opposed

      validates :matter_opposed, presence: true, unless: :draft?
    end
  end
end
