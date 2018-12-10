module Citizens
  class OwnHomeForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :own_home

    validates :own_home, presence: { message: 'blank' }
  end
end
