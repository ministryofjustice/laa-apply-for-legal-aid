module UploadedEvidenceHelper
  def evidence_message(legal_aid_application, evidence_type_translation)
    if legal_aid_application.required_document_categories.size == 1
      single_evidence_message(legal_aid_application, evidence_type_translation)
    else
      multiple_evidence_message(legal_aid_application)
    end
  end

private

  def single_evidence_message(legal_aid_application, evidence_type_translation)
    evidence = legal_aid_application.required_document_categories.first
    content_tag(:div, class: "govuk-body") do
      if legal_aid_application.section_8_proceedings?
        t("#{prefix}.section_8_evidence")
      elsif evidence_type_translation.present?
        t("#{prefix}.single_item", evidence_type: evidence_type_translation)
      else
        t("#{prefix}.single_non_specific_item", item: t("#{prefix}.#{evidence}"))
      end
    end
  end

  def multiple_evidence_message(legal_aid_application)
    matter_type = legal_aid_application.public_law_family_proceedings? ? "" : "for Section 8 proceedings"
    content_tag(:div, t("#{prefix}.list_text"), class: "govuk-body") +
      govuk_list(
        legal_aid_application.required_document_categories.map do |evidence|
          t("#{prefix}.#{evidence}", benefit: legal_aid_application&.dwp_override&.passporting_benefit&.titleize, matter_type:)
        end,
        type: :bullet,
      )
  end

  def prefix
    "providers.uploaded_evidence_collections.upload_evidence"
  end
end
