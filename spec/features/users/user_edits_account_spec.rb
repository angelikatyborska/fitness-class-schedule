require'rails_helper'

feature 'User edits account', js: true do
    let!(:user) { create :user }

    background do
      log_in user

      visit root_path
      click_link user.email
      click_link 'Settings'
    end

    scenario 'changes password' do
      find('.user_password').fill_in 'Password', with: 'password1234'
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

      click_link 'Log In'
      expect(page).to have_button 'Log In'

      fill_in 'Email', with: user.email
      find('.user_password').fill_in 'Password', with: 'password1234'

      click_button 'Log In'
      expect(page).to have_content user.email
    end
end