require'rails_helper'

feature 'Admin creates a schedule item' do
  let!(:room) { create(:room) }
  let!(:trainer) { create(:trainer) }
  let!(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now + 1.day) }
  let!(:admin) { create(:admin_user) }

  background do
    log_in admin

    visit root_path
    click_link 'Admin panel'
    click_link 'Schedule items'
    click_link 'Add'
  end

  scenario 'with valid input' do
    expect {
      select_time tomorrow, from: 'schedule_item_start'

      fill_in 'Duration', with: 45
      fill_in 'Capacity', with: 10
      fill_in 'Activity', with: 'ABT'

      click_button 'Save'
    }.to change(ScheduleItem, :count).by(1)

    expect(page).to have_content 'ABT'
    expect(page).to have_content I18n.l(tomorrow, format: :simple_date)
    expect(page).to have_content I18n.l(tomorrow, format: :simple_time)
  end

  scenario 'with invalid input' do
    expect {
      select_time (tomorrow - 1.hour), from: 'schedule_item_start'

      fill_in 'Duration', with: 45
      fill_in 'Capacity', with: 10
      fill_in 'Activity', with: 'ABT'

      click_button 'Save'
    }.not_to change(ScheduleItem, :count)

    expect(page).to have_content 'can\'t be that early'
  end
end