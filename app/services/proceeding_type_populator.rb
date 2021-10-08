require 'csv'

class ProceedingTypePopulator
  def self.call
    new.call
  end

  def call
    file_path = Rails.root.join('db/seeds/legal_framework/proceeding_types.csv').freeze

    default_service_level = ServiceLevel.find_by!(service_level_number: 3)

    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      proceeding_type = ProceedingType.where(code: row[:code]).first_or_initialize
      proceeding_type.update! row.to_h.merge(default_service_level_id: default_service_level.id)
    end

    populate_default_cost_limitations
  end

  def populate_default_cost_limitations
    pts = ProceedingType.all
    pts.each { |pt| add_cost_limitations(pt) }
  end

  def add_cost_limitations(proceeding_type)
    find_or_create_dcl(proceeding_type: proceeding_type, cost_type: 'substantive', start_date: Date.parse('1970-01-01'), value: 25_000.0)
    find_or_create_dcl(proceeding_type: proceeding_type, cost_type: 'delegated_functions', start_date: Date.parse('1970-01-01'), value: 1_350.0)
    find_or_create_dcl(proceeding_type: proceeding_type, cost_type: 'delegated_functions', start_date: Date.parse('2021-09-13'), value: 2_250.0)
  end

  def find_or_create_dcl(proceeding_type:, cost_type:, start_date:, value:)
    dcl = DefaultCostLimitation.find_by(proceeding_type: proceeding_type, cost_type: cost_type, start_date: start_date, value: value)
    return if dcl.present?

    DefaultCostLimitation.create!(proceeding_type: proceeding_type, cost_type: cost_type, start_date: start_date, value: value)
  end
end
