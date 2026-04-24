module Editing
  class MeritsCleaner
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      destroy_task_list_items!
      update_other_attributes!
      destroy_task_list!
      destroy_evidence!
      destroy_cfe_result!
    end

  private

    attr_reader :legal_aid_application

    def destroy_task_list_items!
      destroy_namespaced_associations(legal_aid_application, :ApplicationMeritsTask)

      legal_aid_application.proceedings.each do |proceeding|
        destroy_namespaced_associations(proceeding, :ProceedingMeritsTask)
      end
    end

    def update_other_attributes!
      legal_aid_application.update!(
        in_scope_of_laspo: nil,
        separate_representation_required: nil,
      )

      legal_aid_application.applicant.update!(relationship_to_children: nil)
    end

    def destroy_task_list!
      legal_aid_application.legal_framework_merits_task_list&.destroy!
    end

    def destroy_evidence!
      destroy_statement_of_case_evidence!
      destroy_uploaded_evidence_collection!
    end

    def destroy_statement_of_case_evidence!
      legal_aid_application.attachments.statement_of_case.each(&:destroy!)
      legal_aid_application.attachments.statement_of_case_pdf.each(&:destroy!)
    end

    def destroy_uploaded_evidence_collection!
      legal_aid_application.attachments.where(attachment_type: uploaded_evidence_attachment_types).find_each(&:destroy!)
      legal_aid_application.uploaded_evidence_collection&.destroy!
    end

    # Here we use the `display_on_evidence_upload` boolean to determine which attachments can be deleted as part
    # of the merits flow, plus any pdf equivalents of those.
    #
    def uploaded_evidence_attachment_types
      uploaded_evidence_attachment_types = DocumentCategory.where(display_on_evidence_upload: true).pluck(:name)
      uploaded_evidence_attachment_types + uploaded_evidence_attachment_types.map { |name| "#{name}_pdf" }
    end

    # CHECK: Do we NEED to delete CFE result here, It will make a new query and use that anyway. But we might want to consider tidying up
    # to remove redundent submissions, results and histories (or not)?!
    #
    # TODO: cfe submission has one [latest] result and many submissions each with submission histories. We could just delete all cfe submissionss, but we should
    # add a dependent destroy on the submission histories relation if so.
    def destroy_cfe_result!
      # legal_aid_application.cfe_result&.destroy!
      # legal_aid_application.cfe_submissions&.destroy_all
    end

    def destroy_namespaced_associations(parent_record, namespace)
      parent_record.class.reflect_on_all_associations.each do |assoc|
        next if assoc.options[:through]

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
          child_record_or_records&.destroy!
        when :has_many, :has_and_belongs_to_many
          puts "DESTROYING #{namespace} association #{assoc.name} that uses macro #{assoc.macro} with ids #{child_record_or_records&.pluck(:id)}" if child_record_or_records.present?
          child_record_or_records&.destroy_all
        end
        # rubocop:enable Rails/Output
      end
    end
  end
end
