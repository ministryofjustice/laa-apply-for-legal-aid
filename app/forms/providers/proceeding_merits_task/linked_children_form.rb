module Providers
  module ProceedingMeritsTask
    class LinkedChildrenForm < BaseForm
      form_for ::ProceedingMeritsTask::ProceedingLinkedChild

      attr_accessor :linked_children

      validate :one_selected_child?, unless: :draft?

      def value_list
        @value_list ||= legal_aid_application.involved_children.map do |child|
          { id: child.id, name: child.full_name, is_checked: children_ids.any?(child.id) }
        end
      end

      def save
        return false unless valid?

        update_involved_children_on_proceeding
      end
      alias_method :save!, :save

      def save_as_draft
        @draft = true
        save! unless update_involved_children_on_proceeding || all_entries_blank?
      end

    private

      def update_involved_children_on_proceeding
        ActiveRecord::Base.transaction do
          proceeding.involved_children.delete_all
          linked_children.filter_map(&:presence).each do |child_id|
            proceeding.proceeding_linked_children.create!(involved_child_id: child_id)
          end
        end
      rescue StandardError
        false
      end

      def one_selected_child?
        errors.add :linked_children, error_message if no_children_selected?
      end

      def error_message
        I18n.t("providers.proceeding_merits_task.linked_children.show.error")
      end

      def no_children_selected?
        linked_children.all?("")
      end

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def proceeding
        @proceeding ||= model
      end

      def children_ids
        @children_ids ||= proceeding.involved_children.map(&:id)
      end
    end
  end
end
