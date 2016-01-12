require 'rails_helper'

feature 'Admin deletes a trainer', js: true do
  let!(:trainer) { create(:trainer) }
  let!(:admin) { create(:admin_user) }

  background do
    log_in admin
  end

  scenario do
    visit root_path

    click_link 'Admin panel'
    within '.admin-panel' do
      click_link 'Trainers'
    end

    expect(page).to have_content trainer
    expect(page).to have_content trainer.description

    expect {
      click_link 'Delete'
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
    }.to change(Trainer, :count).by(-1)

    expect(current_path).to eq admin_trainers_path

    expect(page).not_to have_content trainer
    expect(page).not_to have_content trainer.description
  end
end