class Restriction < ApplicationRecord
  NAMES = %i[
    reposession_or_deferred_interest
    subject_matter_of_dispute
    foreign_exchange_controls
    restraint_or_freezing_order
    bankruptcy
    held_overseas
  ].freeze

  has_many :legal_aid_application_restrictions
  has_many :legal_aid_applications, through: :legal_aid_application_restrictions

  validates :name, presence: true, uniqueness: true

  def self.populate
    # using pluck rather than `find_or_create` in the iteration to reduce SQL calls
    existing = pluck(:name).map(&:to_sym)
    (NAMES - existing).each { |name| create!(name: name) }
  end

  def label_name
    I18n.t("restrictions.names.#{name}")
  end
end
