module Providers
  class OfficeForm
    include BaseForm

    form_for Provider

    attr_accessor :selected_office_id

    validates :selected_office_id, presence: true

    delegate :firm, to: :model

    before_validation do
      self.selected_office_id = nil unless selected_office_id.in?(model.offices.pluck(:id))
    end
  end
end
