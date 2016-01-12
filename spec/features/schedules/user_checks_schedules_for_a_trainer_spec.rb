require 'rails_helper'

feature 'User check schedules for rooms', js: true do
  let!(:schedule_item) { create(:schedule_item_this_week_in_website_time_zone) }
  let!(:other_schedule_item) { create(:schedule_item_this_week_in_website_time_zone) }

  before :all do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  scenario do
    visit root_path
    find('a', text: 'Trainers').hover
    click_link schedule_item.trainer

    expect(page).to have_content schedule_item
    expect(page).not_to have_content other_schedule_item
  end
end
