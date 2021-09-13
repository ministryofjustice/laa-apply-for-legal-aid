class ReSeed < ActiveRecord::Migration[6.1]
  def up
    Rake::Task['db:seed'].invoke
  end

  def down
    nil
  end
end
