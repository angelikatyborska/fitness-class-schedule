require'rails_helper'

feature 'Guest signs up', js: true do
  scenario 'with a valid email' do
    expect {
      visit root_path
      click_link 'Sign up'
      fill_in 'Email', with: 'user@example.com'
      within '.user_password' do
        fill_in 'Password', with: 'password1234'
      end
      fill_in 'Password confirmation', with: 'password1234'
      click_button 'Sign up'
      wait_for_ajax
    }.to change(User, :count).by(1)

    expect(page).to have_content 'You have signed up successfully'
    expect(current_path).to eq root_path
  end

  scenario 'with an invalid email' do
    create(:user, email: 'user@example.com')

    expect {
      visit root_path
      click_link 'Sign up'
      fill_in 'Email', with: 'user@example.com'
      within '.user_password' do
        fill_in 'Password', with: 'password1234'
      end
      fill_in 'Password confirmation', with: 'password1234'
      click_button 'Sign up'
    }.not_to change(User, :count)

    expect(page).to have_content 'has already been taken'
  end
end