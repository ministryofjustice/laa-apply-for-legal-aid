require 'csv'

file_path = Rails.root.join('db', 'seeds', 'proceedings.csv')

data = CSV.read(file_path)
data.shift

data.each do |row|
  code, ccms_code, _ccms_category_of_law_code, _ccms_category_of_law, _ccms_matter_type_code, _ccms_matter_type, _current, meaning, description = row
  Proceeding.where(code: code).first_or_create do |proceeding|

    proceeding.ccms_code = ccms_code
    proceeding.meaning = meaning
    proceeding.description = description
  end
end
