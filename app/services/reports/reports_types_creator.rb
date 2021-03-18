module Reports
  class ReportsTypesCreator # rubocop:disable Metrics/ClassLength
    include ActiveModel::Model

    def self.call(params)
      new(params).call
    end

    attr_reader :application_type,
                :submitted_to_ccms,
                :capital_assessment_result,
                :records_to,
                :records_from,
                :payload_attrs

    validate :validate_required

    def initialize(params)
      @application_type = params[:application_type]
      @submitted_to_ccms = params[:submitted_to_ccms]
      @capital_assessment_result = params[:capital_assessment_result]
      @payload_attrs = params[:payload_attrs]
      @records_from = process_date(params, :records_from) || Date.parse('2019-12-01')
      @records_to = process_date(params, :records_to) || Date.current
    end

    def call
      search_applications if valid?
      self
    end

    def generate_csv
      CSV.generate do |csv|
        if @results.present?
          csv << %w[application_ref case_ccms_reference] + default_opts[:payload_attrs]
          @results.each do |row|
            csv << row.map { |v| "\"#{v}\"" }
          end
        end
      end
    end

    private

    def default_opts
      @default_opts ||= {
        passported: application_type != 'A' && application_type,
        submitted_to_ccms: submitted_to_ccms == 'true',
        assessment_result: capital_assessment_result.last != '' && capital_assessment_result,
        payload_attrs: separate_attrs(payload_attrs)
      }
    end

    def validate_required
      errors.add(:application_type, I18n.t('activemodel.errors.models.reports.application_type')) if application_type.empty?
      errors.add(:submitted_to_ccms, I18n.t('activemodel.errors.models.reports.submitted_to_ccms')) if submitted_to_ccms.empty?
    end

    def separate_attrs(str)
      return [] if !str || str.strip.empty?

      str.split(/\r\n|,|\s/).reject(&:empty?).map(&:upcase)
    end

    def process_date(params, date_type)
      date_params = params.select { |key, _value| key.to_s.include? date_type.to_s }
      return if date_params.values.first.empty?

      Date.parse("#{date_params[:"#{date_type}_1i"]}-#{date_params[:"#{date_type}_2i"]}-#{date_params[:"#{date_type}_3i"]}")
    end

    def find_application_ids
      # get application ids with a benefit check result within time range
      laa_ids = BenefitCheckResult
                .where('created_at >= ?', "#{records_from.strftime('%Y-%m-%d')} 00:00:00.000000")
                .where('created_at <= ?', "#{records_to.strftime('%Y-%m-%d')} 23:59:59.999999")

      # distinguish whether a passported or non-passported application
      if default_opts[:passported]
        laa_ids = laa_ids.where(result: default_opts[:passported] == 'P' ? 'Yes' : 'No')
      end

      # then get ids
      laa_ids.pluck(:legal_aid_application_id)
    end

    def find_latest_application(id:)
      CFE::BaseResult.where(legal_aid_application_id: id).order('created_at DESC').first
    end

    def filter_by_assessment_result(ids)
      return ids unless default_opts[:assessment_result]

      new_ids = []
      # get the latest CFE result (in case of multiple attempts/corrections) for an application
      # using the base class; this is to accommodate for different CFE result versions
      ids.each do |id|
        record = find_latest_application(id: id)
        next unless record

        hash = JSON.parse record.result
        # get either V1 or V2 CFE assessment result
        result = hash['assessment_result'] || hash.dig('assessment', 'capital', 'assessment_result')
        new_ids << id if default_opts[:assessment_result].include? result
      end

      new_ids
    end

    def ccms_submission(id)
      if default_opts[:submitted_to_ccms]
        CCMS::Submission.find_by(legal_aid_application_id: id, aasm_state: 'completed')
      else
        CCMS::Submission.find_by(legal_aid_application_id: id)
      end
    end

    def extract_attributes_from_history(hist)
      Nokogiri::XML(hist.request).remove_namespaces!.xpath('//Attributes//Attribute//Attribute')
    end

    def siblings_response_value(siblings)
      siblings.detect { |s| s.name == 'ResponseValue' }.text
    end

    def process_payload_attrs(result, laa_ref, ccms_hist) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return result unless default_opts[:payload_attrs].any? && ccms_hist

      xml_key_values = []
      attrs = extract_attributes_from_history(ccms_hist)

      default_opts[:payload_attrs].each do |payload_attr|
        dups = []
        case_review_attrs = attrs.select { |a| a.text == payload_attr }

        case_review_attrs.each do |attr|
          next if dups.include? laa_ref

          dups << laa_ref
          siblings = attr.parent.children
          xml_key_values << siblings_response_value(siblings)
        end
      end

      result + xml_key_values
    end

    def process_result(laa_ref, ccms_ref, ccms_hist)
      result = [laa_ref]
      result << ccms_ref if ccms_ref
      application_ccms_history = ccms_hist&.find_by(to_state: 'case_submitted')

      @results << process_payload_attrs(result, laa_ref, application_ccms_history)
    end

    def search_applications
      @results = []
      application_ids = filter_by_assessment_result(find_application_ids)

      application_ids.each do |id|
        ccms = ccms_submission(id)
        ccms_ref = ccms&.case_ccms_reference
        laa = LegalAidApplication.find_by(id: id)
        ccms_hist = laa&.ccms_submission&.submission_history

        process_result(laa.application_ref, ccms_ref, ccms_hist) unless default_opts[:submitted_to_ccms] && !ccms
      end
    end
  end
end
