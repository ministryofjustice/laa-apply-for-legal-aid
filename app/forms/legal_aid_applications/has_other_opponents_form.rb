module LegalAidApplications
  class HasOtherOpponentsForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :has_other_opponents

    validates :has_other_opponents, presence: true, unless: :draft?

    def has_other_opponents?
      @has_other_opponents == "true"
    end
  end
end
