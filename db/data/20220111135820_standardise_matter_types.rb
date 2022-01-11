# frozen_string_literal: true

class StandardiseMatterTypes < ActiveRecord::Migration[6.1]
  def up
    execute "UPDATE proceedings set matter_type = 'Section 8 orders' where ccms_matter_code = 'KSEC8'"
    execute "UPDATE proceedings set matter_type = 'Domestic abuse' where ccms_matter_code = 'MINJN'"
    Setting.setting.update!(digest_extracted_at: 10.years.ago)
  end

  def down
    nil
  end
end
