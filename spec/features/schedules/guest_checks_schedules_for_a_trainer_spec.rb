require 'rails_helper'

feature 'Guest check schedules for a trainer' do
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
    click_button 'Trainer'
    click_link schedule_item.trainer

    expect(page).to have_content schedule_item
    expect(page).not_to have_content other_schedule_item
  end
end
