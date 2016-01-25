require 'rails_helper'

RSpec.feature 'admin checks attendance', js: true do
  let!(:schedule_item) { create :schedule_item_next_week_in_website_time_zone }
  let!(:loyal_client) { create :user }
  let!(:slacker) { create :user }
  let!(:new_client) { create :user }

  let!(:reservations) do
    User.all.each.with_object([]) do |user, reservations|
      reservations << create(:reservation, user: user, schedule_item: schedule_item)
    end
  end

  let!(:admin) { create :admin_user }

  background do
    login_as admin, scope: :user

    visit root_path
    click_link 'Admin Panel'
    click_link I18n.t('user.admin_panel.schedule_items')
  end

  scenario do
    expect(page).to have_content 'Upcoming'
    expect(page).to have_content schedule_item
    click_link 'Check attendance'

    expect(page).to have_content loyal_client
    expect(page).to have_content slacker
    expect(page).to have_content new_client

    within '#' + loyal_client.reservations.first.decorate.css_id do
      click_link 'Confirm attendance'
      within '.status' do
        expect(page).to have_content 'Yes'
      end
    end

    within '#' + slacker.reservations.first.decorate.css_id do
      click_link 'Confirm absence'
      within '.status' do
        expect(page).to have_content 'No'
      end
    end

    within '#' + new_client.reservations.first.decorate.css_id do
      within '.status' do
        expect(page).to have_content '?'
      end
    end
  end
end