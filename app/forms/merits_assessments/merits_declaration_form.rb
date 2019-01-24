module MeritsAssessments
  class MeritsDeclarationForm
    include BaseForm

    form_for MeritsAssessment

    attr_accessor :client_merits_declaration
  end
end
