require'rails_helper'

feature 'Guest signs up', js: true do
  scenario 'with a valid email' do
    visit root_path
    click_link 'Sign Up'
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    fill_in 'Email', with: 'user@example.com'
    within '.user_password' do
      fill_in 'Password', with: 'password1234'
    end
    fill_in 'Password confirmation', with: 'password1234'
    click_button 'Sign Up'

    expect(page).to have_content 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
    expect(current_path).to eq root_path
  end

  scenario 'with an invalid email' do
    create(:user, email: 'user@example.com')

    visit root_path
    click_link 'Sign Up'
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    fill_in 'Email', with: 'user@example.com'
    within '.user_password' do
      fill_in 'Password', with: 'password1234'
    end
    fill_in 'Password confirmation', with: 'password1234'
    click_button 'Sign Up'

    expect(page).to have_content 'has already been taken'
  end
end