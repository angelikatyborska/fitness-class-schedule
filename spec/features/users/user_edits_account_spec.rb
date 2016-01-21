require'rails_helper'

feature 'User edits account', js: true do
    let!(:user) { create(:user) }

    background do
      log_in user
    end

    scenario 'changes password' do
      visit root_path
      click_link user.email
      click_link 'Settings'
      within '.user_password' do
        fill_in 'Password', with: 'password1234'
      end
      fill_in 'Password confirmation', with: 'password1234'
      fill_in 'Current password', with: user.password

      click_button 'Save'
      expect(page).to have_content 'updated successfully'
      click_button 'Close'

      expect(page).to have_content user.email
      click_link user.email

      click_link 'Log Out'
      expect(page).to have_content 'Logged out successfully'
      click_button 'Close'
      expect(page).not_to have_content user.email

      click_link 'Log In'

      fill_in 'Email', with: user.email
      within '.user_password' do
        fill_in 'Password', with: 'password1234'
      end

      click_button 'Log In'
      expect(page).to have_content user.email
    end
end