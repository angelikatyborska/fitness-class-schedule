require 'rails_helper'

feature 'Admin creates a fitness class', js: true do
  let!(:admin) { create(:admin_user) }
  let!(:ann) { create(:trainer, first_name: 'Ann') }

  background do
    log_in admin

    visit root_path
    click_link 'Admin panel'
    within '.admin-panel' do
      click_link 'Trainers'
    end
  end

  scenario 'with valid input' do
    expect(page).to have_content 'Ann'
    expect(page).not_to have_content 'Mary'

    click_link 'Edit'
    fill_in 'First name', with: 'Mary'
    click_button 'Save'

    expect(page).not_to have_content 'Ann'
    expect(page).to have_content 'Mary'
  end
end