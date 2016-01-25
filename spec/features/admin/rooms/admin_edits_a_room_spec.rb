require 'rails_helper'

feature 'Admin edits a room', js: true do
  let!(:admin) { create :admin_user }
  let!(:spinning_room) { create :room, name: 'Spinning room' }

  background do
    login_as admin, scope: :user
  end

  scenario 'with valid input' do
    visit root_path

    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Locations'

    expect(page).to have_content 'Spinning room'
    expect(page).not_to have_content 'Spinning hall'

    click_link 'Edit'
    fill_in 'Name', with: 'Spinning hall'
    click_button 'Save'

    expect(page).not_to have_content 'Spinning room'
    expect(page).to have_content 'Spinning hall'
  end

  scenario 'by adding and deleting a photo' do
    visit root_path

    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Locations'

    click_link 'Edit'
    expect(page).not_to have_selector('.admin-gallery img')

    expect(page).to have_css('form.edit_room')
    click_link 'Add'
    expect(page).to have_content('Add a photo to the gallery')
    attach_file 'room_photo[photo]', Rails.root.join('spec', 'support', 'images', 'room.jpg')
    find('.new_room_photo').click_button 'Save'

    find(:first, '.admin-gallery .th').hover
    click_link 'Delete'

    expect(page).not_to have_selector('.admin-gallery img')
  end
end