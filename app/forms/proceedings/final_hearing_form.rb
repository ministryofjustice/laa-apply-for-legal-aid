module Proceedings
  class FinalHearingForm < BaseForm
    form_for FinalHearing

    attr_accessor :work_type,
                  :listed,
                  :date_1i,
                  :date_2i,
                  :date_3i,
                  :details,
                  :proceeding_id

    attr_writer :date

    validates :work_type, inclusion: { in: [:substantive, :emergency, "substantive", "emergency"] }
    validates :listed, inclusion: { in: [true, false, "true", "false"] }
    validates :date, date: true, allow_nil: true, if: :date_required?
    validates :date, presence: true, if: :date_required?
    validates :details, presence: true, if: :details_required?

    before_validation :clear_date_fields, unless: :date_required?
    before_validation :clear_details, if: :date_required?

    def date
      return @date if @date.present?
      return if date_fields.blank?
      return date_fields.input_field_values if date_fields.partially_complete? || date_fields.form_date_invalid?

      @date = attributes[:date] = date_fields.form_date
    end

  private

    def clear_details
      attributes[:details] = nil
    end

    def clear_date_fields
      attributes[:date] = nil
      attributes[:date_3i] = nil
      attributes[:date_2i] = nil
      attributes[:date_1i] = nil
    end

    def date_required?
      listed.to_s.in? [true, "true"]
    end

    def details_required?
      listed.to_s.in? [false, "false"]
    end

    def exclude_from_model
      date_fields.fields
    end

    def date_fields
      @date_fields ||= DateFieldBuilder.new(
        form: self,
        model:,
        method: :date,
        prefix: :date_,
        suffix: :gov_uk,
      )
    end
  end
end
