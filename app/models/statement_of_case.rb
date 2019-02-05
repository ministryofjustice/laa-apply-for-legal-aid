class StatementOfCase < ApplicationRecord
  belongs_to :legal_aid_application

  validates_presence_of :statement
end
