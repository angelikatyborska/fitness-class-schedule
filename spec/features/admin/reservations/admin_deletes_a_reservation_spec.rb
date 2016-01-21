require 'rails_helper'

RSpec.feature 'admin deletes a reservation', js: true do
  let!(:admin) { create(:admin_user) }
  let!(:schedule_item) { create(:schedule_item_next_week_in_website_time_zone) }
  let!(:user) { create(:user) }
  let!(:reservation) { create(:reservation, user: user, schedule_item: schedule_item) }

  background do
    login_as(admin, scope: :user)

    visit root_path
    click_link 'Admin Panel'
    click_link 'Schedule'
  end

  scenario do
    expect(page).to have_content schedule_item
    click_link 'Check in'
    expect(page).to have_content user
    click_link 'Delete'
    page.driver.browser.switch_to.alert.accept
    expect(page).not_to have_content user
  end
end