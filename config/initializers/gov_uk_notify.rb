ActionMailer::Base.add_delivery_method :govuk_notify, GovukNotifyRails::Delivery,
                                       api_key: ENV['GOVUK_NOTIFY_API_KEY']
