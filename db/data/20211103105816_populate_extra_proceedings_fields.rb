# frozen_string_literal: true

class PopulateExtraProceedingsFields < ActiveRecord::Migration[6.1]
  def up
    Proceeding.all.each do |proceeding|
      pt = ProceedingType.find_by(ccms_code: proceeding.ccms_code)
      proceeding.update!(matter_type: pt.ccms_matter,
                         category_of_law: pt.ccms_category_law,
                         category_law_code: pt.ccms_category_law_code)
    end
  end

  def down
    ActiveRecord::Base.connection.execute 'UPDATE proceedings SET matter_type = NULL, category_of_law = NULL, category_law_code = NULL'
  end
end
