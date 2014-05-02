module EventsHelper
  def attending_class(event)
    'class="attending_event"'.html_safe if event.user_attending?(current_user)
  end

  def day_names
    I18n.t(:"date.day_names")
  end

  def days_of_week_for_select
    day_names.map {|name| [name, day_names.index(name).to_s]}
  end

  def recur_types_for_select
    Event.recur_types.map do |name, value|
      [I18n.t("events.recur_types.#{name}"), name]
    end
  end
end
