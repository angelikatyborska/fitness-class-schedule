require 'rails_helper'

feature 'Admin deletes a room', js: true do
  let!(:room) { create :room }
  let!(:admin) { create :admin_user }

  background do
    login_as admin, scope: :user
  end

  scenario do
    visit root_path

    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Locations'

    expect(page).to have_content room.name
    expect(page).to have_content room.description

    expect {
      click_link 'Delete'
      expect(page).to have_content 'Location has been deleted!'
    }.to change(Room, :count).by(-1)

    expect(current_path).to eq admin_rooms_path

    expect(page).not_to have_content room.name
    expect(page).not_to have_content room.description
  end
end