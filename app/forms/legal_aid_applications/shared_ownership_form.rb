module LegalAidApplications
  class SharedOwnershipForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :shared_ownership

    validates :shared_ownership, presence: { message: 'blank' }, unless: :draft?

    after_validation { model.percentage_home = nil unless shared_ownership? }

    delegate :shared_ownership?, to: :model
  end
end
