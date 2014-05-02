class EventsPolicy < Policy
  def allowed_current_action?
    if in_action?(:index, :new, :create)
      true
    elsif in_action?(:edit, :update, :destroy)
      user.admin? || record.user == user
    end
  end

  def filtered_params
    params.require(:event).permit(:name, :date, :starts_at, :ends_at, :day_of_week, :recur_type, :description, :capacity)
  end
end
