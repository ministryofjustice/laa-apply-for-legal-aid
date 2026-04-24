module Editing
  class MeritsCleaner
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      # rubocop:disable Rails/Output
      puts "deleting merits data for legal aid application #{legal_aid_application.id}"
      # rubocop:enable Rails/Output

      # destroy the task list itself
      # legal_aid_application.legal_framework_merits_task_list.destroy!

      # destroy application merits tasks data
      destroy_namespaced_associations(legal_aid_application, :ApplicationMeritsTask)

      # destroy proceedings merits tasks data
      destroy_namespaced_associations(legal_aid_application, :ProceedingMeritsTask)

      legal_aid_application.proceedings.each do |proceeding|
        destroy_namespaced_associations(proceeding, :ProceedingMeritsTask)
      end

      # CHECK: Do we need to delete statement of case documents and other evidence (TEST)

      # Delete all supporting evidence, Gateway evidence etc
      # legal_aid_application.uploaded_evidence_collections.destroy_all
    end

  private

    attr_reader :legal_aid_application

    def destroy_namespaced_associations(parent_record, namespace)
      parent_record.class.reflect_on_all_associations.each do |assoc|
        # This avoids crashes for polymorphic relations where klass isn’t fixed.
        klass = begin
          assoc.klass
        rescue StandardError
          nil
        end

        next unless klass
        next unless klass.name.start_with?(namespace.to_s)

        child_record_or_records = parent_record.public_send(assoc.name)

        # rubocop:disable Rails/Output
        case assoc.macro
        when :has_one, :belongs_to
          puts "DESTROYING #{namespace} association #{assoc.name} that uses macro #{assoc.macro} with id #{child_record_or_records&.id}" if child_record_or_records.present?
          # child_record_or_records&.destroy
        when :has_many, :has_and_belongs_to_many
          puts "DESTROYING #{namespace} association #{assoc.name} that uses macro #{assoc.macro} with ids #{child_record_or_records&.pluck(:id)}" if child_record_or_records.present?
          # child_record_or_records&.destroy_all
        end
        # rubocop:enable Rails/Output
      end
    end
  end
end
