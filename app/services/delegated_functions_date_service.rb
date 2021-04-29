class DelegatedFunctionsDateService
  delegate :earliest_delegated_functions_date, to: :laa

  attr_reader :laa

  def self.call(laa, draft_selected: false)
    new(laa, draft_selected).call
  end

  def initialize(laa, draft_selected)
    @laa = laa
    @draft_selected = draft_selected
  end

  def call
    update_deadline
    schedule_reminders unless @draft_selected
    true
  end

  private

  def update_deadline
    laa.update!(substantive_application_deadline_on: new_deadline)
  end

  def new_deadline
    earliest_delegated_functions_date ? SubstantiveApplicationDeadlineCalculator.call(earliest_delegated_functions_date) : nil
  end

  def schedule_reminders
    delete_existing_reminders
    create_new_reminders
  end

  def delete_existing_reminders
    ScheduledMailing.where(mailer_klass: 'SubmitApplicationReminderMailer', legal_aid_application_id: laa.id).map(&:destroy!)
  end

  def create_new_reminders
    SubmitApplicationReminderService.new(@laa).send_email if deadline_in_future?
  end

  def deadline_in_future?
    return false if @laa.substantive_application_deadline_on.nil?

    @laa.substantive_application_deadline_on > Time.zone.now
  end
end
