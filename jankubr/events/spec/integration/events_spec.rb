require 'spec_helper'

describe 'Events' do
  it "allows a user to create, update and delete an event; admin can update any event" do
    user = FactoryGirl.create(:user)
    login_as(user)
    click_link('Add a new event')
    click_button('Save')
    #validation works
    page.should have_content('Object could not be saved')
    page.should have_content("Name can't be blank")

    fill_in 'Name', with: 'Ruby meetup'
    fill_in 'Date', with: 1.day.from_now.to_date
    fill_in 'Starts at', with: '18:00'
    fill_in 'Ends at', with: '20:00'
    fill_in 'Description', with: 'Meetup of Rubyists'
    click_button('Save')
    #event was created
    event = Event.last
    event.name.should == 'Ruby meetup'
    event.date.should == 1.day.from_now.to_date
    event.starts_at.hour.should == 18
    event.ends_at.hour.should == 20
    event.description.should == 'Meetup of Rubyists'
    event.capacity.should == nil
    page.should have_content(event.name)

    click_link('Update event')
    fill_in 'Name', with: 'Python meetup'
    fill_in 'Capacity', with: 20
    click_button('Save')
    event.reload.name.should == 'Python meetup'
    event.capacity.should == 20
    page.should have_content(event.name)

    user2 = FactoryGirl.create(:user)
    login_as(user2)
    #another user sees the event
    page.should have_content(event.name)
    #but cannot update it
    page.should_not have_content('Update event')
    visit "/events/#{event.id}/edit"
    page.should_not have_content('Name')
    page.should have_content("The page cannot be accessed")
    visit events_path
    #only if they are an admin
    user2.update_attributes(role: 'admin')
    visit events_path
    click_link('Update event')
    fill_in 'Name', with: 'Scala meetup'
    click_button('Save')
    event.reload.name.should == 'Scala meetup'
    page.should have_content(event.name)

    login_as(user)
    click_link('Delete event')
    Event.count.should == 0
  end

  it "allows a user to create an event which repeats each of week" do
    user = FactoryGirl.create(:user)
    login_as(user)
    click_link('Add a new event')
    click_button('Save')

    fill_in 'Name', with: 'Ruby meetup'
    select 'Wednesday', from: 'Every'
    fill_in 'Starts at', with: '18:00'
    fill_in 'Ends at', with: '20:00'
    fill_in 'Description', with: 'Meetup of Rubyists'
    click_button('Save')
    #event was created
    event = Event.last
    event.name.should == 'Ruby meetup'
    event.date.should == nil
    event.day_of_week.should == 3
    event.description.should == 'Meetup of Rubyists'
    event.capacity.should == nil
    event.event_dates.size.should > 0
    page.should have_content(event.name)
  end

  it "allows user to join and leave an event" do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, capacity: 20)
    event_date = event.event_dates.last
    login_as(user)
    click_button('I will attend this event')

    event_date.reload.user_attending?(user).should == true
    page.should have_content('You are attending this event')
    page.should have_content('1 of 20')

    click_button('Leave')
    page.should_not have_content('You are attending this event')
    event_date.reload.user_attending?(user).should == false
  end

  it "makes sure user cannot join event capacity of which as been reached" do
    user = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, capacity: 1)
    JoinEventDate.new(event.event_dates.last).join(user)

    login_as(user2)
    page.should_not have_content('I will attend this event')
    page.should have_content('Capacity reached')

    event.update_attributes(capacity: 2)
    visit '/'
    page.should have_button('I will attend this event')
    page.should_not have_content('Capacity reached')
  end

  it "makes sure user cannot join event if it stats less than a day from now" do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, date: Date.today)

    login_as(user)
    page.should_not have_content('I will attend this event')
    page.should have_content('Too late to join')

    event.update_attributes(date: Date.tomorrow)
    visit '/'
    page.should have_button('I will attend this event')
    page.should_not have_content('Too late to join')
  end

  it "allows admin to see emails of all attendees" do
    user = FactoryGirl.create(:user)
    admin = FactoryGirl.create(:user)
    admin.update_attributes(role: 'admin')
    event = FactoryGirl.create(:event)
    JoinEventDate.new(event.event_dates.last).join(user)

    login_as(admin)
    page.should have_content(user.email)
    page.should_not have_content(event.user.email)

    login_as(user)
    page.should_not have_content(user.email)
    page.should_not have_content(event.user.email)
  end
end
