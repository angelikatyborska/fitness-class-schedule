require 'rails_helper'

feature 'User deletes a reservation', js: true do
  let!(:schedule_item) { create(:schedule_item_this_week_in_website_time_zone) }
  let!(:user) { create(:user) }
  let!(:reservation) { create(:reservation, user: user, schedule_item: schedule_item) }

  before :all do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  scenario 'via user panel' do
    login_as(user, scope: :user)
    visit root_path
    click_link user.email
    click_link 'My reservations'
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