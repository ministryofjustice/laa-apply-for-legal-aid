# Add common methods to forms.
# Usage:
#   Add the following to the form:
#
#       include ActiveModel::Model
#       include BaseForm
#       extend BaseForm::ClassMethods
#

module BaseForm
  module ClassMethods
    def form_for(klass)
      @model_class = klass
    end

    def model_class
      @model_class || raise('Model class must be defined. Use: `form_for ClassName`')
    end

    def model_name
      ActiveModel::Name.new(self, nil, model_class.to_s)
    end
  end

  def initialize(params={})
    @params = params.symbolize_keys
    super params[self.class.model_class.to_s.underscore.to_sym]
  end

  def params
    @params
  end

  def model
    @model ||= self.class.model_class.new
  end

  def save
    return false unless self.valid?
    model.attributes = attributes.except(*exclude_from_model.map(&:to_s))
    model.save(validate: false)
  end

  # List of form attributes not to be passed to model
  def exclude_from_model
    []
  end

  def legal_aid_application
    @legal_aid_application ||= LegalAidApplication.find(params[:legal_aid_application_id])
  end

  def attributes
    @attributes ||= {}
  end

  private

  # Over-riding ActiveModel::AttributeAssignment method to store attributes as they are built
  def _assign_attribute(k, v)
    attributes[k] = v
    super
  end
end
