module TransactionTypeHelper
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
