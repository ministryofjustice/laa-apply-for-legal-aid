# Join object between LegalAidApplication and Restriction
class LegalAidApplicationRestriction < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :restriction
end
