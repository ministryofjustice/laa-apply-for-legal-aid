# frozen_string_literal: true

class AddCCMSMatterCodeToProccedings < ActiveRecord::Migration[6.1]
  def up
    Proceeding.all.each do |proceeding|
      pt = ProceedingType.find_by(ccms_code: proceeding.ccms_code)
      proceeding.update!(ccms_matter_code: pt.ccms_matter_code)
    end
  end

  def down
    ActiveRecord::Base.connection.execute 'UPDATE proceedings SET ccms_matter_code = NULL'
  end
end
