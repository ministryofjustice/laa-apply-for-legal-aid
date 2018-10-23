class BaseForm
  include ActiveModel::Model

  class << self
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

  def model
    @model ||= self.class.model_class.new
  end
end
