class Provider < ApplicationRecord
  devise :saml_authenticatable, :trackable
  serialize :roles
  serialize :offices

  belongs_to :firm, optional: true
  belongs_to :office, optional: true

  has_many :legal_aid_applications

  def update_details
    return update_details_directly unless firm

    ProviderDetailsCreatorWorker.perform_async(id)
  end

  def update_details_directly
    ProviderDetailsCreator.call(self)
  end
end
