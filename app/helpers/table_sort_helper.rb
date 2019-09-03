module TableSortHelper
  # Usage
  #   For a th tag for a sortable date column with the text content of "Foo":
  #     sort_column_th type: :date, content: 'Foo'
  #
  #   types are :date, :numeric, and :alphabetic
  #
  #   If the column is already sorted add `currently_sorted` with the direction:
  #      sort_column_th type: :date, content: 'Foo', currently_sorted: :desc
  #
  #   directions are :desc and :asc
  #
  #   If the column is to be combined right on small screens:
  #     sort_column_th type: :date, content: 'Foo', combine_right: {at: 470, append: 'Bar}
  #
  #   where at: is the width below which the column will be combined (options are 470 and 555)
  #   and append: is the contented that will be appended to the main content when the columns are combined
  #
  def sort_column_th(type:, content:, combine_right: {}, currently_sorted: nil)
    combine_right_at = combine_right[:at]
    klasses = %w[govuk-table__header sort]
    klasses += ['table-combine_right_if_narrow', "narrow_#{combine_right_at}"] if combine_right_at
    klasses << 'govuk-table__header--numeric' if type == :numeric
    klasses << "header-sort-#{currently_sorted}" if currently_sorted
    content_tag(:th, class: klasses, scope: 'col', 'data-sort-type' => type) do
      sort_span_by +
        sort_span_content(content) +
        sort_span_combine_right(combine_right) +
        sort_span_sort_indicator(type, currently_sorted)
    end
  end

  def sort_span_by
    content_tag :span, "#{t('sorting.sort_by')} ", class: 'govuk-visually-hidden'
  end

  def sort_span_content(content)
    content_tag :span, content, class: 'aria-sort-description'
  end

  def sort_span_sort_indicator(type = nil, currently_sorted = nil)
    content_tag(
      :span,
      sort_span_screen_reader_sort_indicator(type, currently_sorted),
      class: 'sort-direction-indicator'
    )
  end

  def sort_span_screen_reader_sort_indicator(type, currently_sorted)
    screen_reader_hint = sort_hint(type: type, direction: currently_sorted)
    content = screen_reader_hint && "(#{screen_reader_hint})".html_safe
    content_tag(
      :span,
      content,
      class: 'screen-reader-sort-indicator govuk-visually-hidden'
    )
  end

  def sort_span_combine_right(options = {})
    return '' if options.empty?

    content_tag :span, " #{options[:append]}", class: 'table-hidden_right_title'
  end

  def sort_hint(type: :numeric, direction: :desc)
    return unless direction

    labels = sort_hint_labels[type]
    return I18n.t("sorted_#{direction}_html") unless labels

    labels.reverse! if direction == :desc
    labels.map! { |label| I18n.t("sorting.#{label}") }
    from, to = labels
    I18n.t('sorting.currently_sorted_html', from: from, to: to)
  end

  def sort_hint_labels
    {
      numeric: %i[smallest largest],
      alphabetic: %i[a z],
      date: %i[newest oldest]
    }
  end
end
