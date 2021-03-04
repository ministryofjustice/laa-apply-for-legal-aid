module Reports
  class ReportsTypesCreator
    include ActiveModel::Model

    def self.call(params)
      new(params).call
    end

    attr_reader :application_type,
                :submitted_to_ccms,
                :capital_assessment_result,
                :records_to,
                :records_from,
                :payload_attrs,
                :matches

    validate :validate_required

    def initialize(params)
      @application_type = params[:application_type]
      @submitted_to_ccms = params[:submitted_to_ccms]
      @capital_assessment_result = params[:capital_assessment_result]
      @payload_attrs = params[:payload_attrs]
      @records_from = process_date(params, 'records_from') || Date.parse('2019-12-01')
      @records_to = process_date(params, 'records_to') || Date.current
    end

    def call
      return self unless valid?

      opts = {
        passported: application_type != 'A' && application_type,
        submitted_to_ccms: submitted_to_ccms == 'true',
        assessment_result: capital_assessment_result.last != '' && capital_assessment_result,
        payload_attrs: separate_attrs(payload_attrs)
      }

      results = find_cases(from: @records_from, to: @records_to, opts: opts)
      @matches = results.present? ? 'Yes' : 'No'

      CSV.open(Rails.root.join('tmp/custom-apply-ccms-report.csv'), 'wb') do |csv|
        if results.present?
          csv << results.first.keys
          results.each do |row|
            csv << row.values.map { |v| "\"#{v}\""}
          end
        end
      end

      self
    end

    private

    def validate_required
      errors.add(:application_type, I18n.t('activemodel.errors.models.reports.application_type')) if application_type.empty?
      errors.add(:submitted_to_ccms, I18n.t('activemodel.errors.models.reports.submitted_to_ccms')) if submitted_to_ccms.empty?
    end

    def separate_attrs(str)
      return [] if !str || str.strip.empty?

      str.split(/\r\n|,|\s/).reject(&:empty?).map(&:upcase)
    end

    def process_date(params, date_type)
      date_params = params.select { |key, _value| key.include? date_type }
      return if date_params.values.first.empty?

      Date.parse("#{date_params["#{date_type}_1i"]}-#{date_params["#{date_type}_2i"]}-#{date_params["#{date_type}_3i"]}")
    end

    def find_cases(from:, to:, opts:)
      results = []

      # get application ids with a benefit check result within time range
      laa_ids = BenefitCheckResult
                  .where('created_at >= ?', from.strftime('%Y-%m-%d') + ' 00:00:00.000000')
                  .where('created_at <= ?', to.strftime('%Y-%m-%d') + ' 23:59:59.999999')

      # distinguish whether a passported or non-passported application
      if opts[:passported]
        laa_ids = laa_ids.where(result: opts[:passported] == 'P' ? 'Yes' : 'No')
      end

      # then get ids
      laa_ids = laa_ids.pluck(:legal_aid_application_id)

      if opts[:assessment_result]
        new_ids = []
        # get the latest CFE result (in case of multiple attempts/corrections) for an application
        # using the base class; this is to accommodate for different CFE result versions
        laa_ids.each do |id|
          record = CFE::BaseResult.where(legal_aid_application_id: id).order("created_at DESC").first
          if record
            hash = JSON.parse record.result
            # get either V1 or V2 CFE assessment result
            result = hash['assessment_result'] || hash.dig('assessment', 'capital', 'assessment_result')
            new_ids << id if opts[:assessment_result].include? result
          end
        end
        laa_ids = new_ids
      end

      laa_ids.each do |id|
        # get CCMS cases that actually succeeded and not failed or retried
        ccms = opts[:submitted_to_ccms] ?
                 CCMS::Submission.find_by(legal_aid_application_id: id, aasm_state: 'completed') :
                 CCMS::Submission.find_by(legal_aid_application_id: id)

        laa = LegalAidApplication.find_by(id: id)
        # ignore any applications that were started and not submitted to ccms
        if ccms
          result = { case_ccms_reference: ccms.case_ccms_reference, application_ref: laa.application_ref }
          application_ccms_history = laa.ccms_submission.submission_history.find_by(to_state: 'case_submitted')

          if opts[:payload_attrs].any? && application_ccms_history
            xml_key_values = {}

            doc = Nokogiri::XML(application_ccms_history.request).remove_namespaces!
            attrs = doc.xpath('//Attributes//Attribute//Attribute')

            opts[:payload_attrs].each do |payload_attr|
              dups = []
              case_review_attrs = attrs.select{ |a| a.text == payload_attr }

              case_review_attrs.each do |attr|
                siblings = attr.parent.children
                response_value = siblings.detect{ |s| s.name == 'ResponseValue' }.text

                unless dups.include?(laa.application_ref)
                  dups << laa.application_ref
                  xml_key_values[payload_attr.to_sym] = response_value
                end
              end
            end

            result = result.merge(xml_key_values)
          end
          results << result
        end
      end
      results
    end
  end
end
