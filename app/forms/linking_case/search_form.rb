module LinkingCase
  class SearchForm < BaseSearchForm
    form_for LegalAidApplication

    attr_accessor :linkable_case

    def case_found?
      @linkable_case = LegalAidApplication.find_by(application_ref: search_ref)
    end
  end
end
