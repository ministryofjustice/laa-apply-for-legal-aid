class ProceedingType < ApplicationRecord
  has_many :application_proceeding_types
  has_many :legal_aid_applications, through: :application_proceeding_types
  has_many :proceeding_type_scope_limitations
  has_many :eligible_scope_limitations, through: :proceeding_type_scope_limitations, source: :scope_limitation
  belongs_to :default_level_of_service, class_name: 'ServiceLevel', foreign_key: 'default_service_level_id', inverse_of: :proceeding_types

  validates :code, presence: true

  def self.populate
    ProceedingTypePopulator.call
    refresh_textsearchable
  end

  delegate :default_substantive_scope_limitation,
           :default_delegated_functions_scope_limitation, to: :proceeding_type_scope_limitations

  def self.refresh_textsearchable
    query = <<~EOSQL
      UPDATE proceeding_types
      SET textsearchable =
            setweight(to_tsvector(coalesce(meaning,'')), 'A')    ||
            setweight(to_tsvector(coalesce(ccms_category_law, '')), 'B')  ||
            setweight(to_tsvector(coalesce(ccms_matter, '')), 'C')  ||
            setweight(to_tsvector(coalesce(code, '')), 'D')  ||
            setweight(to_tsvector(coalesce(description, '')), 'D')  ||
            setweight(to_tsvector(coalesce(additional_search_terms,'')), 'D');
    EOSQL

    connection.execute(query)
  end

  def domestic_abuse?
    ccms_matter == 'Domestic Abuse'
  end
end
