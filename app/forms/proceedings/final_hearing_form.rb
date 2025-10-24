module Proceedings
  class FinalHearingForm < BaseForm
    form_for FinalHearing

    attr_accessor :work_type,
                  :listed,
                  :date,
                  :details,
                  :proceeding_id

    validates :work_type, inclusion: { in: %i[substantive emergency] }
    validates :listed, inclusion: { in: %w[true false] }
    validates :details, presence: true, if: :details_required?
    validates :date, presence: true, if: :date_required?

    validates :date,
              date: {
                format: Date::DATE_FORMATS[:date_picker_parse_format],
                strict_pattern: Date::DATE_PATTERNS[:date_picker_strict],
              },
              allow_nil: true,
              if: :date_required?

    before_validation :clear_date_fields, unless: :date_required?
    before_validation :clear_details, if: :date_required?

  private

    def clear_details
      attributes[:details] = nil
    end

    def clear_date_fields
      attributes[:date] = nil
    end

    def date_required?
      listed.to_s == "true"
    end

    def details_required?
      listed.to_s == "false"
    end
  end
end
