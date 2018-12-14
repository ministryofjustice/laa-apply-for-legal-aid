require 'csv'

file_path = Rails.root.join('db', 'seeds', 'proceeding_types.csv')

data = CSV.read(file_path)
data.shift

data.each do |row|
  code, ccms_code, ccms_category_of_law_code, ccms_category_of_law, ccms_matter_type_code, ccms_matter_type, _current, meaning, description = row
  proceeding_type = ProceedingType.where(code: code).first_or_initialize
  attrs = {
    ccms_code: ccms_code,
    meaning: meaning,
    description: description,
    ccms_category_law: ccms_category_of_law,
    ccms_category_law_code: ccms_category_of_law_code,
    ccms_matter: ccms_matter_type,
    ccms_matter_code: ccms_matter_type_code
  }
  proceeding_type.update_attributes(attrs)
end
