class ProceedingTypeFullTextSearch
  Result = Struct.new(:id, :meaning, :description, :rank)

  def self.call(search_terms)
    new(search_terms).call
  end

  def initialize(search_terms)
    @ts_query = ts_query_transform(search_terms)
  end

  def call
    result_set = ProceedingType.connection.exec_query(query_string,
                                                      '-- PROCEEDING TYPE FULL TEXT SEARCH ---',
                                                      [[nil, @ts_query]],
                                                      prepare: true)
    result_set.map { |row| instantiate_result(row) }
  end

  private

  def instantiate_result(row)
    Result.new(row['id'], row['meaning'].strip, row['description'].strip, row['rank'])
  end

  def ts_query_transform(search_terms)
    # transform the query into a form suitable for postgres to_tsquery function
    # "Once upon a time in a galaxy" => "Once & upon & a & time & in & a & galaxy"
    search_terms.split(/\s+/).join(' & ').gsub('& & &', '&')
  end

  def query_string
    <<~END_OF_QUERY
      SELECT id,#{' '}
        meaning,
        description,
        ts_rank(textsearchable, query) AS rank
      FROM proceeding_types, to_tsquery($1) AS query
      WHERE query @@ textsearchable
      ORDER BY rank DESC
      LIMIT 10;

    END_OF_QUERY
  end
end

# ActiveRecord::Base.connection.exec_query('SELECT code, meaning from proceeding_types where code = $1', 'SQL', [[nil, 'PR0206']], prepare: true)
#
# ActiveRecord::Base.connection.exec_query("SELECT code, meaning from proceeding_types where textsearchable @@ to_tsquery($1)", '---MY SQL---', [[nil, 'order & protection']], prepare: true)
#
# select code,
