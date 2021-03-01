class ProceedingTypeFullTextSearch
  Result = Struct.new(:id, :meaning, :code, :description, :rank)

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
    @ts_query = search_terms
  end

  def call
    result_set = ProceedingType.where(fields_contain_substr_query, *substr_query_args).limit(8)
    result_set.map { |row| instantiate_result(row) }
  end

  private

  def instantiate_result(row)
    Result.new(row['id'], row['meaning'].strip, row['code'], row['description'].strip, row['rank'])
  end

  def fields_contain_substr_query
    SEARCH_FIELDS.reduce('') do |str, field|
      str << "lower(#{field}) like ?"
      str << ' OR ' unless field == SEARCH_FIELDS.last
      str
    end
  end

  def substr_query_args
    args = []
    query_arg = "%#{@ts_query.downcase}%"
    SEARCH_FIELDS.count.times { args << query_arg }
    args
  end
end
