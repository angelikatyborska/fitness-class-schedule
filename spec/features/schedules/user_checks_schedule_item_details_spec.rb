require 'rails_helper'

feature 'User check schedule item details', js: true do
   before :all do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

   let!(:schedule_item) { create :schedule_item_this_week_in_website_time_zone }

   context 'without logging in' do
    scenario do
      visit root_path
      click_link schedule_item
      wait_for_ajax
      expect(page).to have_content I18n.l(schedule_item.start.in_website_time_zone, format: :human_friendly_date_with_time)
      expect(page).to have_content schedule_item.room.name
      expect(page).to have_content schedule_item.duration
      expect(page).to have_content schedule_item.trainer.first_name
      expect(page).to have_content schedule_item.capacity
      expect(page).to have_content schedule_item.free_spots

      expect(page).not_to have_selector(:link_or_button, 'Edit')
      expect(page).not_to have_selector(:link_or_button, 'Delete')
      expect(page).not_to have_selector(:link_or_button, 'Reserve')
    end
  end

  context 'with logging in' do
    let!(:user) { create :user }

    background do
      login_as(user, scope: :user)
    end

    scenario do
      visit root_path
      click_link schedule_item
      wait_for_ajax
      expect(page).to have_content I18n.l(schedule_item.start.in_website_time_zone, format: :human_friendly_date_with_time)
      expect(page).to have_content schedule_item.room.name
      expect(page).to have_content schedule_item.duration
      expect(page).to have_content schedule_item.trainer.first_name
      expect(page).to have_content schedule_item.capacity
      expect(page).to have_content schedule_item.free_spots

      expect(page).not_to have_selector(:link_or_button, 'Edit')
      expect(page).not_to have_selector(:link_or_button, 'Delete')
      expect(page).to have_selector(:link_or_button, 'Reserve')
    end
  end
end
