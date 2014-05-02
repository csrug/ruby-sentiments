require 'spec_helper'

describe EventForm do

  it "emails attendees about changes in their event" do
    user = FactoryGirl.create(:user)
    admin = FactoryGirl.create(:user, role: 'admin')
    event = FactoryGirl.create(:event)
    JoinEventDate.new(event.event_dates.last).join(user)

    ActionMailer::Base.deliveries.clear
    EventForm.new(admin, name: 'Different').update(event)

    event.reload.name.should == 'Different'
    ActionMailer::Base.deliveries.size.should == 1
    mail = ActionMailer::Base.deliveries.last
    mail.bcc.should == [user.email]
    mail.subject.should == 'Event update'
    mail.body.raw_source.should =~ /Different/
  end
end
