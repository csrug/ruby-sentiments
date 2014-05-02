class EventForm
  attr_accessor :params, :user, :event

  def initialize(user, params)
    self.params = params
    self.user = user
  end

  def create
    self.event = Event.new(params.merge(user_id: user.id))
    event.save
  end

  def update(event)
    self.event = event
    event_before_update = event.dup
    return false unless @event.update_attributes(params)
    if @event.event_attendees.any?
      EventMailer.event_updated(event_before_update, @event).deliver
    end
    true
  end
end
