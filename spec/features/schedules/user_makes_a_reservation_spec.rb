require 'rails_helper'

feature 'User makes a reservation', js: true do
  let!(:schedule_item) { create(:schedule_item_this_week_in_website_time_zone, activity: 'ABT') }
  let!(:user) { create(:user) }

  before :all do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  scenario 'without logging in' do
    visit root_path
    click_link 'ABT'
    expect(page).not_to have_content 'Reserve'
  end

  scenario 'with logging in' do
    log_in user
    visit root_path
    click_link 'ABT'
    expect(page).to have_selector("input[type=submit][value='Reserve']")
    expect {
      click_button 'Reserve'
      wait_for_ajax
    }.to change(user.reservations, :count).by(1)
    expect(page).to have_content 'Your reservation has been added.'
  end
end