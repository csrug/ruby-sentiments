Events for Ruby sentiments
==========================

ROUND 4
--------------
1.Regular events can repeat also every two weeks, not just weekly.
Added a choice of weekly/biweekly to events and altered the future event dates generator to skip weeks if requested. Used the new enum functionality of Rails 4.1 to store the repetition kind.
2. Admin can change every event.
Allowed admin to do anything in EventsPolicy and updated the integration test to test for it.
3. When an event is changed, attendees are informed about these changes through email.

ROUND 3
--------------
1. Two types of events: one-off (with a fixed date) and recurring (day in week).
The recurring events are a bit tricky. I see two possible approaches. One is to only store the required repetition in the database and only
display the repeated events in the UI. So event.day_of_week would have the day of week when the event should be repeated, e.g. Monday.
Then the UI would show this event for every coming Monday. This is the "correct" "computer science" solution. It is easy to save, but difficult
to display. A lot of work would need to done in Rails as the database cannot help us much here. We couldn't use the typical pagination. The user registration for an event would need to hold the date for which the user registered. And while building the list of events to display,
we'd need to look up these registration based on their date.
As usual I chose a simpler not a "computer science correct", pragmatic solution. A new model EventDate is introduced which holds all the individual events of an event. If it is a one off event, it only has one event_date. If it is a recurring event, it generates even_dates to
the future far enough for us to care (say 1 year). The display of these information then is then very simple. The attendee registration just
points to the given event_date. Every night a cron task generates more event_dates to the future. It might get a bit tricky to generate event_dates correctly, but after they are in the database, everything is very simple. The solution is optimized for reading.
2. Users can join an event the latest one day before it starts.
The idea here is that I never show the Join button for an event the start of which is less than 1 day away (or which already happened).
That way our service object JoinEvent or the controller doesn't need to do this check in a very user-friendly way. The check only servers as a protection for a misuse (sending a POST request directly - as from the UI it is not possible). So the JoinEvent service simply returns false if
the event answers false in the method can_be_joined?. Controller than simply reports "Couldn't join the event". It's something a regular user
never sees as the join button is hidden also when the event returns false from the method can_be_joined? Instead a text
along the lines of "Too late to join" is shown.

ROUND 2
--------------

1. User can cancel his registration to event.
Added a service object LeaveEvent that handles this. Controller action only delegates to this object.
2. Event has limit of attendees.
Added capacity field to events table. When capacity reached (as determined by the Event#capacity_reached? method), the "I will attend this event"
button is not shown.
Also the service object JoinEvent won't let a user join if the capacity is reached (If user tries to go around the missing
button). For this I needed a first unit test.
3. User can be an admin and then see a list of emails of attending users.
As I had a complete user management in place, simple addition of "role" column in users gave me the ability to have an admin user.
One bigger change was needed here, the serialized "attending_user_ids" column from events table had to be replaced with a join table.
Otherwise, to show the attendees' emails, I'd need to query them with a separate call for each event or do some custom ugly pre-fetching.
Using a join table I can use standard Rails' "includes": Event.includes(:users).order('date, starts_at').


ROUND 1
--------------
I approached this as a normal on-the-job task, meaning I used the tools I'm most familiar with and I know
I can rely on during daily development and will not let me down when I need to develop features fast.

That said, I used this opportunity to showcase some concepts that worked for me while working on a bigger Rails
app (30k lines not counting tests) that may be a bit premature here.

Policy objects
--------------
Access rights are controlled by policy objects, one for each controller. EventsPolicy is a child of Policy
that has the basic setup. In EventsPolicy you only whitelist actions that the current user can access. This
can also depend on the record that they currently work on. Policies are also used in views to show/hide
action links, e.g. allowed?(:destroy, event).
Policies can also scope collections based on what the current user can see.

Service objects
---------------
Lately I prefer to keep my models as light as possible. They should contain method that directly relate
to their data and mostly only to reading them. In Event I have user_attending?(user), which is only a convenience
method over the model's data.
When the user wants to join an event though, I don't put that code in the model, but create a service object instead.
Service objects are a layer between my controllers and models. They do more complicated data crunching and are
responsible for saving the model in the database.

View inheritance
----------------
application/new.html.erb defines a common new.html.erb template that does not need to be repeated for each controller.

Integration tests
-----------------
I prefer capybara integration (feature) tests over any other type of tests.

SCSS variables
----------------
I take advantage of SCSS variables by defining all colors in colors.css.scss as variables and
using only the variables in other CSS files.

