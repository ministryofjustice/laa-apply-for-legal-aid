module HasOtherProceedingsHelper
  def show_check_proceeding_warning?(application)
    application.proceedings.any? do |application_proceeding|
      lfa_proceedings.any? do |lfa_proceeding|
        lfa_proceeding.ccms_matter_code != application_proceeding.ccms_matter_code && lfa_proceeding.meaning.casecmp?(application_proceeding.meaning)
      end
    end
  end

private

  def lfa_proceedings
    @lfa_proceedings ||= LegalFramework::ProceedingTypes::All.call
  end
end
