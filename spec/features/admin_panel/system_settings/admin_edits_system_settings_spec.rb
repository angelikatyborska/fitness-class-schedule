require'rails_helper'

feature 'admin edits system setting', js: true do
  let!(:admin) { create(:admin_user) }

  background do
    log_in admin
  end

    scenario 'checks settings' do
      visit root_path
      click_link 'Admin panel'
      click_link 'System settings'
      expect(page).to have_content 'Day starts'
      expect(page).to have_content 'Day ends'
      expect(page).to have_content 'Site title'
      expect(page).to have_content 'Schedule time zone'
    end

  scenario 'edits site title' do
    visit root_path
    click_link 'Admin panel'
    click_link 'System settings'
    fill_in 'Site title', with: 'My Awesome Site'
    click_button 'Save'
    wait_for_ajax
    visit root_path
    within 'nav' do
      expect(page).to have_content 'My Awesome Site'
    end
  end

  scenario 'edits schedule time zone' do
    create(:schedule_item, start: Time.now.utc.beginning_of_day + 12.hours )

    visit root_path
    click_link 'Admin panel'
    click_link 'System settings'
    select '0', from: 'Day starts'
    select '23', from: 'Day ends'
    select 'UTC', from: 'Schedule time zone'
    click_button 'Save'
    wait_for_ajax

    visit root_path
    within '.schedule' do
      expect(page).to have_content '12:00'
    end

    click_link 'Admin panel'
    click_link 'System settings'
    select 'Hawaii', from: 'Schedule time zone'
    click_button 'Save'
    wait_for_ajax

    visit root_path
    within '.schedule' do
      expect(page).to have_content '02:00'
    end
  end

end