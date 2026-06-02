# Example class for sharing validation between task list pseudo models and form pseudo models
class ApplicantsDetailsValidator < BaseValidator
  def validate(record)
    record.errors.add(:first_name, :blank) if record.first_name.blank?
    record.errors.add(:last_name, :blank) if record.last_name.blank?
    record.errors.add(:date_of_birth, :blank) if record.date_of_birth.blank?
    record.errors.add(:changed_last_name, :inclusion) if record.changed_last_name.nil? || [true, false].not_include?(record.changed_last_name)
    record.errors.add(:last_name_at_birth, :blank) if record.changed_last_name.to_s == "true" && record.last_name_at_birth.blank?
  end
end
