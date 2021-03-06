require 'rails_helper'

feature 'Admin deletes a schedule item', js: true do
  before :all do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  let!(:schedule_item) { create :schedule_item_this_week_in_website_time_zone }
  let!(:admin) { create :admin_user }

  background do
    login_as admin, scope: :user
  end

  scenario 'from schedule items admin panel' do
    visit root_path

    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Schedule'

    expect(page).to have_content 'Upcoming'
    expect(page).to have_content schedule_item
    expect(page).to have_content I18n.l(schedule_item.start.in_website_time_zone, format: :simple_date)
    expect(page).to have_content I18n.l(schedule_item.start.in_website_time_zone, format: :simple_time)

    expect {
      click_link 'Delete'
      wait_for_ajax
    }.to change(ScheduleItem, :count).by(-1)

    expect(page).not_to have_content schedule_item
    expect(page).not_to have_content I18n.l(schedule_item.start.in_website_time_zone, format: :simple_date)
    expect(page).not_to have_content I18n.l(schedule_item.start.in_website_time_zone, format: :simple_time)
  end

  scenario 'from room schedule' do
    visit root_path

    expect(page).to have_content schedule_item
    click_link schedule_item

    expect {
      click_link 'Delete'
      wait_for_ajax
    }.to change(ScheduleItem, :count).by(-1)

    expect(page).not_to have_content schedule_item
  end
end