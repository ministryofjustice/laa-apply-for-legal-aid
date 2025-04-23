module PaymentsSummaryPartialUrlHelper
  def payments_summary_partial_url(partner, credit, regular_payments, *)
    version = partner == true ? "partners" : "means"
    payment_type = credit == true ? "income" : "outgoing"
    page = regular_payments || partner ? "regular_#{payment_type}s" : "identify_types_of_#{payment_type}"
    url = "providers_legal_aid_application_#{version}_#{page}_path"
    Rails.application.routes.url_helpers.send(url, *)
  end
end
