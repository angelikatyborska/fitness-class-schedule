require 'rails_helper'

include Warden::Test::Helpers
Warden.test_mode!

feature 'Admin creates a schedule item', js: true do
  let!(:room) { create(:room) }
  let!(:trainer) { create(:trainer) }
  let!(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now.in_website_time_zone + 1.day) }
  let!(:fitness_class) { create(:fitness_class) }
  let!(:admin) { create(:admin_user) }

  background do
    login_as(admin, scope: :user)

    visit root_path
    click_link 'Admin panel'
    click_link 'Schedule items'
    click_link 'Add'
  end

  scenario 'with valid input' do
    expect {
      select_datetime tomorrow, from: 'schedule_item_start'

      fill_in 'Duration', with: 45
      fill_in 'Capacity', with: 10
      select fitness_class, from: 'Fitness class'

      click_button 'Save'
    }.to change(ScheduleItem, :count).by(1)

    expect(page).to have_content fitness_class
    expect(page).to have_content I18n.l(tomorrow, format: :simple_date)
    expect(page).to have_content I18n.l(tomorrow, format: :simple_time)
  end

  scenario 'with invalid input' do
    expect {
      select_datetime (tomorrow - 2.days), from: 'schedule_item_start'

      fill_in 'Duration', with: 45
      fill_in 'Capacity', with: 10
      select fitness_class, from: 'Fitness class'

      click_button 'Save'
    }.not_to change(ScheduleItem, :count)

    expect(page).to have_content 'can\'t be in the past'
  end
end