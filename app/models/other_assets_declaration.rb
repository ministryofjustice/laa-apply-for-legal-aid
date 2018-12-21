class OtherAssetsDeclaration < ApplicationRecord
  include Capital
  # include ValueTestable

  belongs_to :legal_aid_application

  def self.non_value_attrs
    %w[id legal_aid_application_id created_at updated_at]
  end
end
