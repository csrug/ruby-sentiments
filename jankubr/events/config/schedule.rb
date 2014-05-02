job_type :runner,  "cd :path && script/rails runner -e :environment ':task' :output"

every :day, at: '4:00am' do
  runner 'Event.update_recurring_events'
end
