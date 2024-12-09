module Providers
  module ApplicationMeritsTask
    class SecondAppealForm < BaseForm
      form_for LegalAidApplication

      attr_accessor :second_appeal

      validates :second_appeal, presence: true, unless: :draft?
    end
  end
end
