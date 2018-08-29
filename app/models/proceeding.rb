class Proceeding < ApplicationRecord
  has_many :application_proceedings
  has_many :legal_aid_applications, through: :application_proceedings
end
