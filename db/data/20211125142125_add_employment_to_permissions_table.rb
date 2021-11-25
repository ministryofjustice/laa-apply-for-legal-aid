# frozen_string_literal: true

class AddEmploymentToPermissionsTable < ActiveRecord::Migration[6.1]
  def up
    Permission.create(role: 'application.non_passported.employment.*', description: 'Can create, edit, delete employment applications')
  end

  def down
    Permission.where(role: 'application.non_passported.employment.*').delete_all
  end
end
