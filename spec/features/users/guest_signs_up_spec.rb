require'rails_helper'

feature 'Guest signs up', js: true do
 let!(:other_user) { create :user, email: 'already_taken@example.com' }

  background do
    visit root_path
    click_link 'Sign Up'
  end

  scenario 'with a valid email' do
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    fill_in 'Email', with: 'user@example.com'
    find('.user_password').fill_in 'Password', with: 'password1234'
    fill_in 'Password confirmation', with: 'password1234'

    click_button 'Sign Up'

    expect(page).to have_content 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
    expect(current_path).to eq root_path
  end

  scenario 'using an email that is already taken' do
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    fill_in 'Email', with: 'already_taken@example.com'
    find('.user_password').fill_in 'Password', with: 'password1234'
    fill_in 'Password confirmation', with: 'password1234'

    click_button 'Sign Up'

    expect(page).to have_content 'has already been taken'
  end
end