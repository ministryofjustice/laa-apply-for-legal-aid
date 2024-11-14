module Providers
  module Means
    module CapitalDisregards
      class AddDetailsForm < BaseForm
        form_for CapitalDisregard

        attr_accessor :payment_reason,
                      :amount,
                      :account_name,
                      :date_received_1i,
                      :date_received_2i,
                      :date_received_3i

        attr_writer :date_received

        validates :payment_reason, presence: { unless: :draft? }, if: :payments_reason_needed?
        validates(
          :amount, presence: { unless: :draft? },
                   currency: { greater_than_or_equal_to: 0, allow_blank: true }
        )
        validates :account_name, presence: { unless: :draft? }
        validates :date_received, date: { not_in_the_future: true }, presence: { unless: :draft? }

        def payments_reason_needed?
          model.name.in?(%w[compensation_for_personal_harm loss_or_harm_relating_to_this_application])
        end

        def initialize(*args)
          super
          set_instance_variables_for_attributes_if_not_set_but_in_model(
            attrs: date_received_fields.fields,
            model_attributes: date_received_fields.model_attributes,
          )
        end

        def date_received
          return @date_received if @date_received.present?
          return if date_received_fields.blank?
          return date_received_fields.input_field_values if date_received_fields.partially_complete? || date_received_fields.form_date_invalid?

          @date_received = attributes[:date_received] = date_received_fields.form_date
        end

        def attributes_to_clean
          [:amount]
        end

      private

        def exclude_from_model
          date_received_fields.fields
        end

        def date_received_fields
          @date_received_fields ||= DateFieldBuilder.new(
            form: self,
            model:,
            method: :date_received,
            prefix: :date_received_,
            suffix: :gov_uk,
          )
        end
      end
    end
  end
end
