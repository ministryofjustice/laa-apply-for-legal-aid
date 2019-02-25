module TransactionTypeHelper
  # hints is a hash with the transaction type names as keys, and the hint texts as values
  # and only includes entries for types that need hints.
  def transaction_type_check_boxes(form:, transaction_types:, hints: {})
    hints.transform_values! { |hint| govuk_hint(hint, class: 'govuk-checkboxes__hint') }
    render(
      'shared/forms/transaction_type_check_boxes',
      form: form,
      transaction_types: transaction_types,
      hints: hints
    )
  end
end
