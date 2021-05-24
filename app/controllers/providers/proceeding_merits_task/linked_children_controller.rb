module Providers
  module ProceedingMeritsTask
    class LinkedChildrenController < ProviderBaseController
      def show
        application_proceeding_type
        involved_children
      end

      def update
        application_proceeding_type
        involved_children.each { |child| update_record(child[:id], child[:name]) }
        update_task_continue_or_draft(proceeding_type.ccms_code.to_sym, :children_proceeding)
      end

      private

      def task_list_should_update?
        application_has_task_list?
      end

      def legal_aid_application
        @legal_aid_application ||= application_proceeding_type.legal_aid_application
      end

      def proceeding_type
        @proceeding_type ||= application_proceeding_type.proceeding_type
      end

      def application_proceeding_type
        @application_proceeding_type ||= ApplicationProceedingType.find(merits_task_list_id)
      end

      def merits_task_list_id
        params['merits_task_list_id']
      end

      def user_selected?(name)
        params[name] == 'true'
      end

      def child_already_added?(id)
        involved_children.detect { |child| child[:id] == id }[:is_checked]
      end

      def involved_children
        @involved_children ||= legal_aid_application.involved_children.map do |child|
          { id: child.id, name: child.full_name, is_checked: children_ids.any?(child.id) }
        end
      end

      def update_record(id, name)
        if user_selected? name
          create_record id unless child_already_added? id
        elsif child_already_added? id
          delete_record id
        end
      end

      def create_record(id)
        application_proceeding_type
          .application_proceeding_type_involved_children
          .create!(involved_child_id: id)
      end

      def delete_record(id)
        application_proceeding_type
          .application_proceeding_type_involved_children
          .find_by(involved_child_id: id).destroy!
      end

      def children_ids
        @children_ids ||= application_proceeding_type.involved_children.map(&:id)
      end
    end
  end
end
