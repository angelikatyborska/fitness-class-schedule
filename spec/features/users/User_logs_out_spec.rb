require'rails_helper'

feature 'User logs out', js: true do
  context 'regular user' do
    let!(:user) { create(:user) }

    background do
      log_in user
    end

    scenario 'anywhere on the page' do
      old_path = current_path
      click_link user.email
      click_link 'Log out'
      wait_for_ajax
      expect(page).to have_content 'Logged out successfully.'
      click_button 'Close'
      expect(current_path).to eq old_path
    end
  end

  context 'admin user' do
    let!(:user) { create(:admin_user) }

    background do
      log_in user
    end

    scenario 'browsing the admin panel' do
      click_link 'Admin panel'
      click_link 'Schedule items'
      click_link user.email
      click_link 'Log out'
      wait_for_ajax
      expect(page).to have_content 'Logged out successfully.'
      click_button 'Close'
      expect(current_path).to eq root_path
    end
  end
end