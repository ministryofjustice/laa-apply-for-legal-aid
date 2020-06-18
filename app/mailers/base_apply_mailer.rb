class BaseApplyMailer < GovukNotifyRails::Mailer
  # this is a hook method that ScheduledMailing can call to see if the mail
  # still needs to be sent.  Override in the subclass if you want anything
  # other than always true
  def self.eligible_for_delivery?(_scheduled_mailing)
    true
  end
end
