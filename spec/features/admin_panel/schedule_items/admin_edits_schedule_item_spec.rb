require'rails_helper'

feature 'Admin edits a schedule item' do
  let!(:schedule_item) { create(:schedule_item, activity: 'ABT') }
  let!(:admin) { create(:admin_user) }

  background do
    log_in admin
  end

  scenario 'with valid input' do
    visit root_path

    click_link 'Admin panel'
    click_link 'Schedule items'

    expect(page).to have_content 'ABT'

    click_link 'Edit'

    expect(current_path).to eq edit_admin_schedule_item_path(schedule_item)

    expect {
      fill_in 'Activity', with: 'TBC'
      click_button 'Save'
    }.to change(ScheduleItem, :count).by(0)

    expect(current_path).to eq admin_schedule_items_path

    expect(page).not_to have_content 'ABT'
    expect(page).to have_content 'TBC'
  end
end