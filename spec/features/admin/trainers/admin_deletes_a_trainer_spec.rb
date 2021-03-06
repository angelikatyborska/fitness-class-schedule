require 'rails_helper'

feature 'Admin deletes a trainer', js: true do
  let!(:trainer) { create :trainer }
  let!(:admin) { create :admin_user }

  background do
    login_as admin, scope: :user
  end

  scenario do
    visit root_path

    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Trainers'

    expect(page).to have_content trainer.first_name
    expect(page).to have_content trainer.description

    expect {
      click_link 'Delete'
      expect(page).to have_content 'Trainer has been deleted!'
    }.to change(Trainer, :count).by(-1)

    expect(current_path).to eq admin_trainers_path

    expect(page).not_to have_content trainer.first_name
    expect(page).not_to have_content trainer.description
  end
end