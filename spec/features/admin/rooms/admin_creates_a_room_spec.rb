require 'rails_helper'

feature 'Admin creates a room' do
  let!(:admin) { create(:admin_user) }

  background do
    login_as(admin, scope: :user)

    visit root_path
    click_link 'Admin Panel'
    within '.admin-panel' do
      click_link 'Locations'
    end
    click_link 'Add'
  end

  scenario 'with valid input' do
    expect {
      fill_in 'Name', with: 'Spinning Room'
      fill_in 'Description', with: 'Filled with 25 professional stationary bikes.'
      click_button 'Save'
    }.to change(Room, :count).by(1)

    expect(page).to have_content 'Spinning Room'
  end

  scenario 'with invalid input' do
    fill_in 'Name', with: 'Spinning Room'
    click_button 'Save'
    expect(page).to have_content 'can\'t be blank'
  end
end