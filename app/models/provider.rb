class Provider < ApplicationRecord
  devise :saml_authenticatable, :trackable
  serialize :roles
end
