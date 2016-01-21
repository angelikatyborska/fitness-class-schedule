require'rails_helper'

feature 'Guest logs in', js: true do
  let!(:user) { create(:user, password: 'password1234') }

  scenario 'with a valid password' do
    visit root_path
    click_link 'Log In'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log In'
    expect(page).to have_content 'Log Out'
    expect(page).to have_content user.email
  end

  scenario 'with an invalid password' do
    visit root_path
    click_link 'Log In'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'invalid_password'
    click_button 'Log In'
    expect(page).to have_content 'Invalid email or password'
    expect(page).not_to have_content 'Log Out'
  end
end