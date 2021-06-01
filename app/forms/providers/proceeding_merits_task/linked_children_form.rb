module Providers
  module ProceedingMeritsTask
    class LinkedChildrenForm
      include BaseForm

      form_for ::ProceedingMeritsTask::ApplicationProceedingTypeLinkedChild

      attr_accessor :linked_children

      validate :one_selected_child?

      def value_list
        @value_list ||= legal_aid_application.involved_children.map do |child|
          { id: child.id, name: child.full_name, is_checked: children_ids.any?(child.id) }
        end
      end

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          application_proceeding_type.involved_children.delete_all
          linked_children.filter_map(&:presence).each do |child_id|
            application_proceeding_type.application_proceeding_type_linked_children.create!(involved_child_id: child_id)
          end
        end
        true
      rescue StandardError
        false
      end

      private

      def one_selected_child?
        errors.add :linked_children, error_message if no_children_selected?
      end

      def error_message
        I18n.t('providers.proceeding_merits_task.linked_children.show.error')
      end

      def no_children_selected?
        linked_children.all?('')
      end

      def legal_aid_application
        @legal_aid_application ||= application_proceeding_type.legal_aid_application
      end

      def application_proceeding_type
        @application_proceeding_type ||= model
      end

      def children_ids
        @children_ids ||= application_proceeding_type.involved_children.map(&:id)
      end
    end
  end
end
