class EventsController < ApplicationController
  def index
    @event_dates = @policy.scope(EventDate.includes(:event, :users).references(:event).order('event_dates.date, starts_at'))
  end

  def new
    @event = Event.new
  end

  def create
    event_form = EventForm.new(current_user, @policy.filtered_params)
    if event_form.create
      flash[:notice] = t('events.saved')
      redirect_to(events_path)
    else
      @event = event_form.event
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if EventForm.new(current_user, @policy.filtered_params).update(@event)
      flash[:notice] = t('events.updated')
      redirect_to(events_path)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    flash[:notice] = t('events.deleted')
    redirect_to(events_path)
  end

private

  def check_rights
    @event = Event.find(params[:id]) if params[:id]
    @policy = EventsPolicy.new(current_user, params, @event)
    @policy.guard!
  end
end
