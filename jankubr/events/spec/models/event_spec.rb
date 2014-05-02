require 'spec_helper'

describe Event do
  it "generates event dates for recurring events" do
    allow(Event).to receive(:generate_days).and_return(7)
    event = nil
    Timecop.travel(Date.new(2014, 4, 30)) do
      event = FactoryGirl.create(:event, day_of_week: 5)
      event.event_dates.size.should == 2
      event.event_dates.map{|ed| ed.date.to_s}.should == ['2014-05-02', '2014-05-09']
    end

    Timecop.travel(Date.new(2014, 5, 1)) do
      Event.update_recurring_events
      event.reload.event_dates.size.should == 2
      event.event_dates.map{|ed| ed.date.to_s}.should == ['2014-05-02', '2014-05-09']
    end

    Timecop.travel(Date.new(2014, 5, 3)) do
      Event.update_recurring_events
      event.reload.event_dates.size.should == 3
      event.event_dates.map{|ed| ed.date.to_s}.should == ['2014-05-02', '2014-05-09', '2014-05-16']
    end
  end

  it "keeps attendees registered on events when generating new dates" do
    allow(Event).to receive(:generate_days).and_return(7)
    event = nil
    user = FactoryGirl.create(:user)
    Timecop.travel(Date.new(2014, 4, 30)) do
      event = FactoryGirl.create(:event, day_of_week: 5)
      JoinEventDate.new(event.event_dates.last).join(user)
      user.reload.events.should == [event]
    end
    Timecop.travel(Date.new(2014, 5, 1)) do
      Event.update_recurring_events
      user.reload.events.should == [event]
    end
    Timecop.travel(Date.new(2014, 5, 3)) do
      Event.update_recurring_events
      user.reload.events.should == [event]
    end
  end

  it "generates event dates for bi-weekly recurring events" do
    allow(Event).to receive(:generate_days).and_return(14)
    event = nil
    Timecop.travel(Date.new(2014, 4, 30)) do
      event = FactoryGirl.create(:event, day_of_week: 5, recur_type: 'biweekly')
      event.event_dates.size.should == 2
      event.event_dates.map{|ed| ed.date.to_s}.should == ['2014-05-02', '2014-05-16']
    end
  end
end
