class EventMailer < ActionMailer::Base
  default from: "from@example.com"

  def event_updated(event_before_update, event_after_update)
    @event_before_update = event_before_update
    @event_after_update = event_after_update
    mail(subject: I18n.t('event_mailer.event_updated.subject'),
         bcc: event_after_update.event_attendees.map{|a| a.user.email})
  end

end
