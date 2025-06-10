module HasOtherProceedingsHelper
  # Where a proceeding could come under more than one matter type (e.g. child arrangement orders come under both PLF and S8), this method is to
  # add warning component to has_other_proceedings page. This is to warn users to check they have selected the correct matter type.
  def show_check_proceeding_warning?(application)
    lfa_index = lfa_proceedings.group_by { |p| p.meaning.downcase }

    application.proceedings.any? do |application_proceeding|
      matching_lfa = lfa_index[application_proceeding.meaning.downcase] || []
      matching_lfa.any? do |lfa_proceeding|
        lfa_proceeding.ccms_matter_code != application_proceeding.ccms_matter_code
      end
    end
  end

private

  def lfa_proceedings
    @lfa_proceedings ||= LegalFramework::ProceedingTypes::All.call
  end
end
