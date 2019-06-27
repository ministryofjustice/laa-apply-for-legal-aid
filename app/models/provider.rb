class Provider < ApplicationRecord
  devise :saml_authenticatable, :trackable
  serialize :roles
  serialize :offices

  has_many :legal_aid_applications

  def retrieve_details
    details = ProviderDetailsRetriever.call(username)
    update!(details_response: details)
  end
end
