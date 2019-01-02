class OtherAssetsDeclaration < ApplicationRecord
  include Capital
  # include ValueTestable

  belongs_to :legal_aid_application
end
