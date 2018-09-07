require 'csv'

file_path = Rails.root.join('db', 'seeds', 'proceeding_types.csv')

data = CSV.read(file_path)
data.shift

data.each do |row|
  code, ccms_code, _ccms_category_of_law_code, _ccms_category_of_law, _ccms_matter_type_code, _ccms_matter_type, _current, meaning, description = row
  ProceedingType.where(code: code).first_or_create do |proceeding_type|
    proceeding_type.ccms_code = ccms_code
    proceeding_type.meaning = meaning
    proceeding_type.description = description
  end
end
