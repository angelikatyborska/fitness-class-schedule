require'rails_helper'

feature 'Admin deletes a schedule item' do
  let!(:schedule_item) { create(:schedule_item) }
  let!(:admin) { create(:admin_user) }

  background do
    log_in admin
  end

  scenario do
    visit root_path

    click_link 'Admin panel'
    click_link 'Schedule items'

    expect(page).to have_content schedule_item.activity
    expect(page).to have_content I18n.l(schedule_item.start, format: :simple_date)
    expect(page).to have_content I18n.l(schedule_item.start, format: :simple_time)

    expect {
      click_link 'Delete'
    }.to change(ScheduleItem, :count).by(-1)

    expect(current_path).to eq admin_schedule_items_path

    expect(page).not_to have_content schedule_item.activity
    expect(page).not_to have_content I18n.l(schedule_item.start, format: :simple_date)
    expect(page).not_to have_content I18n.l(schedule_item.start, format: :simple_time)
  end
end