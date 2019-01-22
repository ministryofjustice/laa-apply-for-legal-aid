class UpdateProviderIdToApplication < ActiveRecord::Migration[5.2]
  def up
    provider_id = Provider.where(username: 'benreid').try(:provider_id)
    return if provider_id.nil?

    LegalAidApplication.where(provider_id: nil).update_all(provider_id: provider_id)
  end
end
