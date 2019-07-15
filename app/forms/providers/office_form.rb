module Providers
  class OfficeForm
    include BaseForm

    form_for Provider

    attr_accessor :office_id

    validates :office_id, presence: true

    delegate :firm, to: :model

    before_validation do
      self.office_id = nil unless office_id.in?(firm.offices.pluck(:id))
    end
  end
end
