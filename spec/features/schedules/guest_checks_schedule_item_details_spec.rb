require 'rails_helper'

feature 'Guest check schedule item details', js: true do
  let!(:schedule_item) { create(:schedule_item_this_week_in_website_time_zone) }

  before :all do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  scenario '' do
    visit root_path
    click_link schedule_item
    wait_for_ajax
    expect(page).to have_content I18n.l(schedule_item.start.in_website_time_zone, format: :human_friendly_date_with_time)
    expect(page).to have_content schedule_item.room.name
    expect(page).to have_content schedule_item.duration
    expect(page).to have_content schedule_item.trainer.first_name
    expect(page).to have_content schedule_item.capacity
    expect(page).to have_content schedule_item.spots_left
  end
end
