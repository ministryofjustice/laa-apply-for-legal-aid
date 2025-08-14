module Proceedings
  class ScopeLimitationsForm < BaseForm
    include ActiveModel::Model

    form_for Proceeding

    attr_accessor :draft, :scopes, :scope_codes, :scope_type

    validate :validate_scope_selected,
             :validate_hearing_dates,
             :validate_limitation_notes

    class << self
      def call(scopes)
        scopes.each do |scope|
          code = scope["code"]
          populate_attr_accessors(code)
          scope["additional_params"].each do |ap|
            case ap["name"]
            when "hearing_date"
              populate_hearing_date_attr_accessors(code)
            when "limitation_note"
              populate_limitation_note_attr_accessors(code)
            end
          end
        end
        new({ scopes: })
      end

      def populate_attr_accessors(code)
        attr_accessor :"meaning_#{code}",
                      :"description_#{code}"
      end

      def populate_hearing_date_attr_accessors(code)
        attr_accessor :"hearing_date_#{code}_1i",
                      :"hearing_date_#{code}_2i",
                      :"hearing_date_#{code}_3i",
                      :"hearing_date_#{code}"
      end

      def populate_limitation_note_attr_accessors(code)
        attr_accessor :"limitation_note_#{code}"
      end
    end

    private_class_method :populate_attr_accessors,
                         :populate_hearing_date_attr_accessors,
                         :populate_limitation_note_attr_accessors

    def save(params)
      update_scope_attributes(params)

      return false unless valid?

      update_populated_dates
      model.scope_limitations.where(scope_type:).destroy_all
      scope_codes.reject!(&:empty?).each do |code|
        model.scope_limitations.create!(scope_type:,
                                        code:,
                                        meaning: meaning_for(code),
                                        description: description_for(code),
                                        hearing_date: hearing_date_for(code),
                                        limitation_note: limitation_note_for(code))
      end
    end
    alias_method :save!, :save

  private

    def update_scope_attributes(params)
      params.each do |key, value|
        __send__(:"#{key}=", value)
      end
    end

    def update_populated_dates
      hearing_dates.each do |code|
        populate_inputted_date(code)
      end
    end

    def populate_inputted_date(code)
      __send__(:"hearing_date_#{code}=", date_fields(code).form_date) if scope_codes.include? code
    end

    def date_fields(code, value = nil)
      DateFieldBuilder.new(
        label: value,
        form: self,
        model: self,
        method: :"hearing_date_#{code}",
        prefix: :"hearing_date_#{code}_",
        suffix: :gov_uk,
      )
    end

    def meaning_for(code)
      __send__(:"meaning_#{code}")
    end

    def description_for(code)
      __send__(:"description_#{code}")
    end

    def hearing_date_for(code)
      __send__(:"hearing_date_#{code}") if additional_hearing_date_param?(code)
    end

    def limitation_note_for(code)
      __send__(:"limitation_note_#{code}") if additional_limitation_note_param?(code)
    end

    def additional_params_for(code)
      scopes.find { |scope| scope["code"] == code }["additional_params"]
    end

    def additional_hearing_date_param?(code)
      additional_params_for(code).pluck("name").include? "hearing_date"
    end

    def additional_limitation_note_param?(code)
      additional_params_for(code).pluck("name").include? "limitation_note"
    end

    def hearing_dates
      @hearing_dates ||= scopes.filter_map { |scope| scope["code"] if additional_hearing_date_param?(scope["code"]) }
    end

    def limitation_notes
      @limitation_notes ||= scopes.filter_map { |scope| scope["code"] if additional_limitation_note_param?(scope["code"]) }
    end

    def validate_scope_selected
      return if draft?

      errors.add :scope_codes, I18n.t("providers.proceeding_loop.select_a_scope_limitation_error") if scope_codes.all?("")
    end

    def mandatory?(type, code)
      additional_params_for(code).find { |ap| ap["name"] == type }["mandatory"]
    end

    def validate_hearing_dates
      return if draft?

      hearing_dates.each do |code|
        next unless mandatory?("hearing_date", code) && scope_codes.include?(code)

        date_field = date_fields(code)
        attr_name = date_field.method
        valid = !date_field.form_date_invalid?

        errors.add attr_name.to_sym, I18n.t("providers.proceeding_loop.enter_valid_hearing_date_error", scope_limitation: meaning_for(code)) unless valid
      end
    end

    def validate_limitation_notes
      return if draft?

      limitation_notes.each do |code|
        if mandatory?("limitation_note", code) && limitation_note_for(code).blank? && scope_codes.include?(code)
          errors.add :"limitation_note_#{code}", I18n.t("providers.proceeding_loop.enter_limitation_note_error", scope_limitation: meaning_for(code))
        end
      end
    end
  end
end
