module Providers
  module ApplicationMeritsTask
    class MatterOpposedForm < BaseForm
      form_for ::ApplicationMeritsTask::MatterOpposition

      attr_accessor :matter_opposed

      validates :matter_opposed, inclusion: %w[true false], unless: :draft?
    end
  end
end
