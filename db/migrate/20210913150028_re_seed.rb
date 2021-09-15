class ReSeed < ActiveRecord::Migration[6.1]
  def up
    ProceedingType.populate
  end

  def down
    nil
  end
end
