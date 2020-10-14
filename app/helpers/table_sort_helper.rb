module TableSortHelper
  # Usage
  #   For a sortable cell (td) within a sortable column with content 'Bar'
  #     sort_column_cell content: 'Bar'
  #
  #   or
  #     sort_column_cell do
  #       'Bar'
  #     end
  #
  #   If the sort criteria is to be specified (that is not sorting on content), use the `sort_by` option
  #     sort_column_cell content: 'Bar', sort_by 'x'
  #
  #   An array can also be used:
  #     sort_column_cell content: 'Bar', sort_by [1,:a]
  #
  #   with the resultant sort criteria being taken from the concatinated array contents.
  #
  #   If the cells needs to combine right on small screens:
  #     sort_column_cell content: 'Bar', combine_right: 470
  #
  #   Options are 470 and 555
  #
  #   Other options will be passed through to the `content_tag` used to build the `td` tag
  #     sort_column_cell content: 'Bar', id: 2
  #
  #   will generate a `td` tag with id '2'
  #
  def sort_column_cell(args, &block)
    combine_right = args.delete(:combine_right)
    sort_by = args.delete(:sort_by)
    content = args.delete(:content) || capture(&block)
    merge_with_class! args, ['table-combine_right_if_narrow', "narrow_#{combine_right}"] if combine_right
    merge_with_class! args, %w[govuk-table__cell sortable-cell]
    args['data-sort-value'] = sort_by.is_a?(Array) ? sort_by.join : sort_by
    if args.delete(:numeric)
      merge_with_class! args, 'govuk-table__cell--numeric'
      args['data-sort-type'] = 'number'
    end
    content_tag :td, content, args
  end

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
    classes = %w[govuk-table__header sort] # sort enables function and wrapping th content in 'sortable-column' span
    classes += ['table-combine_right_if_narrow', "narrow_#{combine_right_at}"] if combine_right_at
    classes << 'govuk-table__header--numeric' if type == :numeric
    classes << "header-sort-#{currently_sorted}" if currently_sorted

    content_tag(:th, role: 'columnheader', scope: 'col', class: classes) do
      content_tag(:span, class: 'aria-sort-description') { content } +
        sort_span_combine_right(combine_right) +
        content_tag(:span, ', button', class: 'govuk-visually-hidden') +
        simple_span_sort_indicator
    end
  end

  def simple_span_sort_indicator
    content_tag(
      :span,
      '',
      class: 'sort-direction-indicator'
    )
  end

  def sort_span_combine_right(options = {})
    return '' if options.empty?

    content_tag :span, " #{options[:append]}", class: 'table-hidden_right_title'
  end
end
