module TransactionTypeHelper
  # hints is a hash with the transaction type names as keys, and the hint texts as values
  # and only includes entries for types that need hints.
  def transaction_type_check_boxes(form:, transaction_types:, hints: {})
    hints.transform_values! { |hint| govuk_hint(hint, class: 'govuk-checkboxes__hint') }
    render(
      'shared/forms/transaction_type_check_boxes',
      form: form,
      transaction_types: transaction_types,
      hints: hints,
      label_method: "#{journey_type}_label_name"
    )
  end

  def sort_category_column_cell(object, transaction_type)
    return sort_category_column_cell_vacant(object, transaction_type) if category_cells_should_be_blank?(object)

    tag_classes = %w[table-category govuk-body-s]
    label = t("activemodel.attributes.transaction_types.name.#{object.transaction_type.name}")
    content = gov_uk_tag(text: label, classes: tag_classes).html_safe

    sort_column_cell(
      id: "Category-#{object.id}",
      sort_by: label,
      content: content
    )
  end

  def sort_category_column_cell_vacant(object, transaction_type)
    label = t("activemodel.attributes.transaction_types.name.#{transaction_type.name}")
    tag_classes = %w[table-category govuk-body-s table-category-vacant]

    content = @transaction_type.name == 'excluded_benefits' ? '' : gov_uk_tag(text: label, classes: tag_classes).html_safe

    sort_column_cell(
      id: "Category-#{object.id}",
      sort_by: 'ZZZ',
      content: content
    )
  end

  def category_cells_should_be_blank?(object)
    object.transaction_type_id.nil? || object.transaction_type.name == 'excluded_benefits'
  end
end
