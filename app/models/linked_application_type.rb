class LinkedApplicationType
  LinkTypeStruct = Struct.new(:code, :description)

  LINK_TYPES = [
    LinkTypeStruct.new(
      code: "FC_LEAD",
      description: "Family",
      label: I18n.t("providers.linking_case_confirmations.show.options.family_link.text"),
      hint: I18n.t("providers.linking_case_confirmations.show.options.family_link.hint"),
    ),
    LinkTypeStruct.new(
      code: "LEGAL",
      description: "Legal",
      label: I18n.t("providers.linking_case_confirmations.show.options.legal_link.text"),
      hint: I18n.t("providers.linking_case_confirmations.show.options.legal_link.hint"),
    ),
  ].freeze

  def self.all
    LINK_TYPES
  end
end
