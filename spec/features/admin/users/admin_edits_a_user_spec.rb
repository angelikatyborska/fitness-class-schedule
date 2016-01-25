require 'rails_helper'

feature 'Admin edits a user' do
  let!(:admin) { create :admin_user }
  let!(:user) { create :user, first_name: 'Bob' }

  background do
    login_as admin, scope: :user

    visit root_path

    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Users'
  end

  scenario 'with valid input' do
    expect(page).to have_content 'Bob'
    expect(page).not_to have_content 'Robert'

    find("##{ user.decorate.css_id }").click_link 'Edit'

    fill_in 'First name', with: 'Robert'
    click_button 'Save'

    expect(page).not_to have_content 'Bob'
    expect(page).to have_content 'Robert'
  end

  scenario 'with invalid input' do
    find("##{ user.decorate.css_id }").click_link 'Edit'

    fill_in 'First name', with: ''
    click_button 'Save'

    expect(page).to have_content 'can\'t be blank'
  end
end