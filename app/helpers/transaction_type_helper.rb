module TransactionTypeHelper
  def sort_category_column_cell(object, transaction_type)
    return sort_category_column_cell_vacant(object, transaction_type) if object.transaction_type_id.nil?

    tag_classes = %w[table-category govuk-body-s]
    label = t("activemodel.attributes.transaction_types.name.#{object.transaction_type.name}")
    content = gov_uk_tag(text: label, classes: tag_classes).html_safe

    sort_column_cell(
      id: "Category-#{object.id}",
      sort_by: label,
      content:,
    )
  end

  def sort_category_column_cell_vacant(object, transaction_type)
    label = t("activemodel.attributes.transaction_types.name.#{transaction_type.name}")
    tag_classes = %w[table-category govuk-body-s table-category-vacant]

    content = gov_uk_tag(text: label, classes: tag_classes).html_safe

    sort_column_cell(
      id: "Category-#{object.id}",
      sort_by: "ZZZ",
      content:,
    )
  end

  def answer_for_transaction_type(legal_aid_application:, transaction_type:)
    total = legal_aid_application.transactions_total_by_category(transaction_type.id)
    has_transaction_type = legal_aid_application.has_transaction_type?(transaction_type)

    if has_transaction_type && total.zero?
      legal_aid_application.uploading_bank_statements? ? t("generic.yes") : t("generic.yes_but_none")
    elsif has_transaction_type && total.positive?
      legal_aid_application.uploading_bank_statements? ? t("generic.yes") : number_to_currency(total)
    else
      t("generic.none")
    end
  end
end
