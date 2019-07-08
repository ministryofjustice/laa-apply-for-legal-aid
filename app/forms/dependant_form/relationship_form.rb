module DependantForm
  class RelationshipForm
    include BaseForm

    form_for Dependant

    attr_accessor :relationship

    validate :relationship_presence

    private

    def relationship_presence
      return if relationship.present?

      errors.add(
        :relationship,
        I18n.t('activemodel.errors.models.dependant.attributes.relationship.blank', name: model.name)
      )
    end
  end
end
