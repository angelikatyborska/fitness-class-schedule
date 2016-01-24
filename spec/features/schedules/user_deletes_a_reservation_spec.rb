require 'rails_helper'

feature 'User deletes a reservation', js: true do
  before :each do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :each do
    Timecop.return
  end

  let!(:schedule_item) { create(
    :schedule_item,
    start: ScheduleItem.beginning_of_day(Time.zone.now.in_website_time_zone.beginning_of_week + 1.day)
  ) }
  let!(:user) { create(:user) }
  let!(:reservation) { create(:reservation, user: user, schedule_item: schedule_item) }

  context 'within time allowed for cancellations' do
    background do
      Timecop.freeze((schedule_item.start.in_website_time_zone - Configurable.cancellation_deadline.hours - 1.hour))
    end

    scenario 'via user panel' do
      login_as(user, scope: :user)
      visit root_path
      click_link user.email
      click_link 'My Reservations'
      expect(page).to have_link 'Cancel'
      expect {
        click_link 'Cancel'
        wait_for_ajax
      }.to change(user.reservations, :count).by(-1)
      expect(page).to have_content 'Your reservation has been deleted.'
    end

    scenario 'via schedule item dialog box' do
      login_as(user, scope: :user)
      visit root_path
      click_link schedule_item
      expect(page).to have_link 'Cancel'
      expect {
        click_link 'Cancel'
        wait_for_ajax
      }.to change(user.reservations, :count).by(-1)
      expect(page).to have_content 'Your reservation has been deleted.'
    end
  end

  context '15 minutes after time allowed for cancellations has passed' do
    background do
      Timecop.freeze(schedule_item.start.in_website_time_zone - (Configurable.cancellation_deadline).hours + 15.minutes)
    end

    scenario 'via user panel' do
      login_as(user, scope: :user)
      visit root_path
      click_link user.email
      click_link 'My Reservations'
      expect(page).to have_link 'Cancel'
      click_link 'Cancel'
      expect(page).to have_content "We're sorry, but cancellations are only allowed up to #{ Configurable.cancellation_deadline } #{ 'hour'.pluralize(Configurable.cancellation_deadline) } before class."
    end

    scenario 'via schedule item dialog box' do
      login_as(user, scope: :user)
      visit root_path
      click_link schedule_item
      expect(page).to have_link 'Cancel'
      click_link 'Cancel'
      expect(page).to have_content "We're sorry, but cancellations are only allowed up to #{ Configurable.cancellation_deadline } #{ 'hour'.pluralize(Configurable.cancellation_deadline) } before class."
    end
  end
end