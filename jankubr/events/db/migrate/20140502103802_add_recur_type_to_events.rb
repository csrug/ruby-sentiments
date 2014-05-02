class AddRecurTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :recur_type, :integer, default: 0
    Event.recurring.update_all(recur_type: 1)
  end
end
