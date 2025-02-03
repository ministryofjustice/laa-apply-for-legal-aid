module UploadedEvidenceHelper
  def evidence_message(required_documents, legal_aid_application, evidence_type_translation)
    if required_documents.size == 1
      single_evidence_message(required_documents.first, legal_aid_application, evidence_type_translation)
    else
      multiple_evidence_message(required_documents, legal_aid_application)
    end
  end

private

  def single_evidence_message(evidence, legal_aid_application, evidence_type_translation)
    content_tag(:div, class: "govuk-body") do
      if legal_aid_application.section_8_proceedings?
        t(".section_8_evidence")
      elsif evidence_type_translation.present?
        t(".single_item", evidence_type: evidence_type_translation)
      else
        t(".single_non_specific_item", item: t(".#{evidence}"))
      end
    end
  end

  def multiple_evidence_message(required_documents, legal_aid_application)
    matter_type = legal_aid_application.public_law_family_proceedings? ? "" : "for Section 8 proceedings"
    content_tag(:div, t(".list_text"), class: "govuk-body") +
      govuk_list(
        required_documents.map { |evidence| t(".#{evidence}", benefit: legal_aid_application&.dwp_override&.passporting_benefit&.titleize, matter_type:) },
        type: :bullet,
      )
  end
end
