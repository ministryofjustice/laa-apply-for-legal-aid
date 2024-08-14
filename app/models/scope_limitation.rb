class ScopeLimitation < ApplicationRecord
  belongs_to :proceeding

  enum :scope_type, { substantive: 0, emergency: 1 }
  scope :emergency, -> { where(scope_type: :emergency) }
  scope :substantive, -> { where(scope_type: :substantive) }

  def description
    if requires_additional_data_merge?
      description_with_additional_data
    else
      self[:description]
    end
  end

private

  def description_with_additional_data
    self[:description].sub(/\[.*\]/, additional_data)
  end

  def additional_data
    return hearing_date.to_s if hearing_date.present?

    limitation_note
  end

  def requires_additional_data_merge?
    self[:description].include?("[") && has_additional_param?
  end

  def has_additional_param?
    hearing_date.present? || limitation_note.present?
  end
end
