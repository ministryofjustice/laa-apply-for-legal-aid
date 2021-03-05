class ProceedingTypeFullTextSearch
  Result = Struct.new(:meaning, :code, :description, :category_law, :matter)

  SEARCH_FIELDS = %i[
    meaning
    description
    ccms_category_law
    ccms_matter
    additional_search_terms
  ].freeze

  def self.call(search_terms)
    new(search_terms).call
  end

  def initialize(search_terms)
    @ts_queries = search_terms.downcase.split.map { |val| "%#{val}%" }
  end

  def call
    result_set = ProceedingType.where(fields_contain_substr_query, *substr_query_args).order(:meaning).limit(8)
    result_set.map { |row| instantiate_result(row) }
  end

  private

  def instantiate_result(row)
    Result.new(row['meaning'].strip, row['code'], row['description'].strip, row['ccms_category_law'].strip, row['ccms_matter'])
  end

  def fields_contain_substr_query
    SEARCH_FIELDS.each_with_object('') do |field, str|
      str << "lower(#{field}) ILIKE ALL ( array[?] )"
      str << ' OR ' unless field == SEARCH_FIELDS.last
      str
    end
  end

  def substr_query_args
    Array.new(SEARCH_FIELDS.count, @ts_queries)
  end
end
