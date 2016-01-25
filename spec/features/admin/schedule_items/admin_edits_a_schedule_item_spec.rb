require 'rails_helper'

feature 'Admin edits a schedule item' do
  let!(:abt) { create :fitness_class, name: 'ABT' }
  let!(:tbc) { create :fitness_class, name: 'TBC' }
  let!(:schedule_item) { create :schedule_item_next_week_in_website_time_zone, fitness_class: abt }
  let!(:admin) { create :admin_user }

  background do
    login_as admin, scope: :user
  end

  scenario 'with valid input' do
    visit root_path

    click_link 'Admin Panel'
    click_link I18n.t('user.admin_panel.schedule_items')

    expect(page).to have_content 'ABT'

    click_link 'Edit'

    expect {
      select 'TBC', from: 'Fitness class'
      click_button 'Save'
    }.to change(ScheduleItem, :count).by(0)

    expect(current_path).to eq schedule_items_path

    expect(page).not_to have_content 'ABT'
    expect(page).to have_content 'TBC'
  end
end