require 'rails_helper'

feature 'Admin creates a trainer', js: true do
  let!(:admin) { create(:admin_user) }

  background do
    log_in admin

    visit root_path
    click_link 'Admin panel'
    within '.admin-panel' do
      click_link 'Trainers'
    end
    click_link 'Add'
  end

  scenario 'with valid input' do
    expect {
      fill_in 'First name', with: 'Ann'
      fill_in 'Last name', with: 'Kowalski'
      fill_in 'Description', with: 'A Zumba instructor licensed by Zumba Fitness, LLC.'
      attach_file 'Photo', Rails.root.join('spec', 'fixtures', 'trainer.png')
      click_button 'Save'
      wait_for_ajax
    }.to change(Trainer, :count).by(1)

    expect(page).to have_content 'Ann'
  end

  scenario 'with invalid input' do
    fill_in 'First name', with: 'Step'
    click_button 'Save'
    expect(page).to have_content 'can\'t be blank'
  end
end