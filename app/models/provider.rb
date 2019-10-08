class Provider < ApplicationRecord
  devise :saml_authenticatable, :trackable
  serialize :roles
  serialize :offices

  belongs_to :firm, optional: true
  belongs_to :selected_office, class_name: :Office, foreign_key: :selected_office_id, optional: true
  has_many :legal_aid_applications
  has_and_belongs_to_many :offices

  def update_details
    return update_details_directly unless firm

    ProviderDetailsCreatorWorker.perform_async(id)
  end

  def update_details_directly
    ProviderDetailsCreator.call(self)
  end

  # TODO: replace with real data once we have it from the provider details API
  def user_login_id
    2_016_472
  end
end
