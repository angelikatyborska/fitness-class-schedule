require 'rails_helper'

feature 'Admin deletes a room', js: true do
  let!(:room) { create(:room) }
  let!(:admin) { create(:admin_user) }

  background do
    login_as(admin, scope: :user)
  end

  scenario do
    visit root_path

    click_link 'Admin panel'
    within '.admin-panel' do
      click_link 'Locations'
    end

    expect(page).to have_content room.name
    expect(page).to have_content room.description

    expect {
      click_link 'Delete'
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
    }.to change(Room, :count).by(-1)

    expect(current_path).to eq admin_rooms_path

    expect(page).not_to have_content room.name
    expect(page).not_to have_content room.description
  end
end