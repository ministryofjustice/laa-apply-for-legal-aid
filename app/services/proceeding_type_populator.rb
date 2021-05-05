require 'csv'

class ProceedingTypePopulator
  FEATURE_FLAGS = {
    KSEC8: 'allow_multiple_proceedings?'
  }.freeze

  def self.call
    new.call
  end

  def call
    file_path = Rails.root.join('db/seeds/legal_framework/proceeding_types.csv').freeze

    default_service_level = ServiceLevel.find_by!(service_level_number: 3)

    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      next unless create_this_row?(row)

      proceeding_type = ProceedingType.where(code: row[:code]).first_or_initialize
      proceeding_type.update! row.to_h.merge(default_service_level_id: default_service_level.id)
    end
  end

  def create_this_row?(row)
    flag_to_check = FEATURE_FLAGS[row[:ccms_matter_code].to_sym]
    return true unless flag_to_check
    return true unless Setting.respond_to?(flag_to_check)

    Setting.send(flag_to_check)
  end
end
