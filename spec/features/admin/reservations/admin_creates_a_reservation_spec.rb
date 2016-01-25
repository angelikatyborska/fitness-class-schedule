require 'rails_helper'

RSpec.feature 'Admin creates a reservation', js: true do
  let!(:admin) { create :admin_user }
  let!(:schedule_item) { create :schedule_item_next_week_in_website_time_zone }
  let!(:user) { create :user }

  background do
    login_as admin, scope: :user

    visit root_path
    page.save_screenshot 'tmp/1.png'

    click_link 'Admin Panel'
    page.save_screenshot 'tmp/2.png'
    click_link 'Schedule'
  end

  scenario do
    expect(page).to have_content schedule_item
    expect(page).to have_link 'Check attendance'

    click_link 'Check attendance'
    expect(page).to have_content 'Reservations for'

    expect(page).not_to have_content user
    expect(page).to have_link 'Add'

    click_link 'Add'
    select user, from: 'reservation[user_id]'
    click_button 'Reserve'
    expect(page).to have_content user
  end
end