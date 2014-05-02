class Event < ActiveRecord::Base
  belongs_to :user
  has_many :event_attendees, dependent: :destroy
  has_many :event_dates, dependent: :destroy

  scope :recurring, -> { where('day_of_week IS NOT NULL') }

  validates_presence_of :name, :starts_at
  validates_presence_of :date, if: ->(e) {e.day_of_week.blank?}
  validates_presence_of :day_of_week, if: ->(e) {e.date.blank?}
  after_save :generate_event_dates

  def self.update_recurring_events
    Event.recurring.each do |event|
      event.generate_event_dates
    end
  end

  def generate_event_dates
    if day_of_week
      delete_future_event_dates if day_of_week_changed?
      now = Time.now
      first_date = current_date = get_closest_date
      while first_date + Event.generate_days.days >= current_date
        event_dates.where(date: current_date).first_or_create!
        current_date += 1.week
      end
    else
      (event_dates.first || event_dates.new).update_attributes!(date: date)
    end
  end

  def self.generate_days
    90
  end

private

  def get_closest_date
    closest_date = Date.today
    while closest_date.wday != day_of_week
      closest_date += 1.day
    end
    closest_date
  end

  def delete_future_event_dates
    EventDate.where(id: event_dates.future).destroy_all
  end
end
