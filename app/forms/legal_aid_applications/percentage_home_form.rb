module LegalAidApplications
  class PercentageHomeForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :percentage_home

    validates :percentage_home, presence: true
    validates :percentage_home, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true
  end
end
