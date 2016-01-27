require 'rails_helper'

feature 'Admin edits a schedule item' do
  let!(:abt) { create :fitness_class, name: 'ABT' }
  let!(:tbc) { create :fitness_class, name: 'TBC' }
  let!(:schedule_item) { create :schedule_item_next_week_in_website_time_zone, fitness_class: abt }
  let!(:admin) { create :admin_user }

  background do
    login_as admin, scope: :user

    visit root_path

    click_link 'Admin Panel'
    click_link I18n.t('user.admin_panel.schedule_items')

    expect(page).to have_content 'ABT'
  end

  context 'without reservations' do
    scenario 'with valid input' do
      click_link 'Edit'
      expect(page).not_to have_content 'users will be notified about the changes via email.'

      expect {
        select 'TBC', from: 'Class'
        click_button 'Save'
      }.to change(ScheduleItem, :count).by(0)

      expect(current_path).to eq schedule_items_path

      expect(page).not_to have_content 'ABT'
      expect(page).to have_content 'TBC'
    end
  end

  context 'with reservations' do
    let!(:reservation) { create :reservation, schedule_item: schedule_item }

    scenario 'admin sees a warning' do
      click_link 'Edit'
      expect(page).to have_content 'You are about to edit a schedule item for which some users already made reservations. Please proceed with caution and be aware that those users will be notified about the changes via email.'
    end
  end
end