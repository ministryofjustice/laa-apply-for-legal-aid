class BaseSearchForm < BaseForm
  APPLICATION_REF_REGEXP = /\AL-[0-9ABCDEFHIJKLMNPRTUVWXY]{3}-[0-9ABCDEFHIJKLMNPRTUVWXY]{3}\z/

  attr_accessor :search_ref

  # TODO: error message locales
  validates :search_ref,
            presence: true,
            format: { with: APPLICATION_REF_REGEXP },
            unless: :draft?

  validate :case_exists, unless: :draft?

  def case_exists
    errors.add(:search_ref, "does not exist") unless case_found?
  end

  def save
    return false unless valid?

    true
  end

  def exclude_from_model
    [:search_ref]
  end
end
