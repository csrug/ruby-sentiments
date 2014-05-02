class JoinEventDate
  attr_accessor :event_date

  def initialize(event_date)
    self.event_date = event_date
  end

  def join(user)
    return false unless event_date.can_be_joined?

    event_date.event_attendees.create(user: user, event: event_date.event).persisted?
  end
end
