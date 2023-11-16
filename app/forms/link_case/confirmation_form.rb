module LinkCase
  class ConfirmationForm < BaseForm
    form_for LinkedApplication

    attr_accessor :link_type_code

    validates :link_type_code, presence: true, unless: proc { draft? }

    def save
      return if invalid? || draft?

      model.update!(link_type_code:)
    end
    alias_method :save!, :save
  end
end
