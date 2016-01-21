require'rails_helper'

feature 'User forgets password', js: true do
  context 'with valid email' do
    let!(:user) { create(:user) }

    scenario '' do
      visit root_path
      click_link 'Log In'
      click_link 'Forgot your password?'
      fill_in 'Email', with: user.email
      click_button 'Reset password'
      expect(page).to have_content 'You will receive an email with instructions on how to reset your password in a few minutes.'
    end
  end

  context 'with invalid email' do
    let!(:user) { create(:user) }

    scenario '' do
      visit root_path
      click_link 'Log In'
      click_link 'Forgot your password?'
      fill_in 'Email', with: 'not_a_valid_email@invalid.com'
      click_button 'Reset password'
      expect(page).to have_content 'not found'
    end
  end
end