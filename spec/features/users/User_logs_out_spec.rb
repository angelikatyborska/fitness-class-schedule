require'rails_helper'

feature 'User logs out', js: true do
  context 'regular user' do
    let!(:user) { create :user }

    background do
      log_in user
    end

    scenario 'anywhere on the page' do
      visit trainers_path
      click_link user.email
      click_link 'Log Out'
      expect(page).to have_content 'Logged out successfully.'
      click_button 'Close'
      expect(current_path).to eq root_path
    end

    scenario 'browsing their reservations' do
      click_link user.email
      click_link 'My Reservations'
      expect(page).to have_content 'Current reservations'
      click_link user.email
      expect(page).to have_link 'Log Out'
      click_link 'Log Out'
      expect(page).to have_content 'Logged out successfully.'
      click_button 'Close'
      expect(current_path).to eq root_path
    end
  end

  context 'admin user' do
    let!(:user) { create :admin_user }

    background do
      log_in user
    end

    scenario 'browsing the admin panel' do
      click_link 'Admin Panel'
      click_link I18n.t('user.admin_panel.schedule_items')
      expect(page).to have_content 'Upcoming'
      click_link user.email
      click_link 'Log Out'
      expect(page).to have_content 'Logged out successfully.'
      click_button 'Close'
      expect(current_path).to eq root_path
    end
  end
end