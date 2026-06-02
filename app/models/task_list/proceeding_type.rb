module TaskList
  class ProceedingType
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :used_delegated_functions, :boolean
    attribute :used_delegated_functions_on, :date
    attribute :client_involvement_type_ccms_code, :string
    attribute :substantive_level_of_service, :string
    attribute :emergency_level_of_service, :string
    attribute :accepted_emergency_defaults, :boolean
    attribute :accepted_substantive_defaults, :boolean
    attribute :ccms_matter_code, :string

    validates :used_delegated_functions, inclusion: [true, false]
    validates :used_delegated_functions_on,
              date: {
                format: Date::DATE_FORMATS[:date_picker_parse_format],
                strict_pattern: Date::DATE_PATTERNS[:date_picker_strict],
                not_in_the_future: true,
                earliest_allowed_date: { date: 12.months.ago.to_date.strftime(Date::DATE_FORMATS[:date_picker_parse_format]) },
              },
              if: proc { |proceeding_type| proceeding_type.used_delegated_functions }
    validates :client_involvement_type_ccms_code, presence: true
    validates :substantive_level_of_service, presence: true
    validates :emergency_level_of_service, presence: true, unless: proc { |proceeding_type| !proceeding_type.used_delegated_functions || proceeding_type.special_children_act? }
    validates :accepted_emergency_defaults, inclusion: [true, false], unless: proc { |proceeding_type| !proceeding_type.used_delegated_functions || proceeding_type.special_children_act? }
    validates :accepted_substantive_defaults, inclusion: [true, false], presence: true

    def special_children_act?
      ccms_matter_code == "KPBLW"
    end
  end
end
