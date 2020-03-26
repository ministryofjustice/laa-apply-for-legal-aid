class ReplaceStateValue < ActiveRecord::Migration[6.0]
  def up
    execute "UPDATE legal_aid_applications SET state = 'provider_assessing_means'
    WHERE state = 'means_completed'"
  end
end
