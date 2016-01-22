require 'rails_helper'

feature 'Admin edits a room', js: true do
  let!(:admin) { create(:admin_user) }
  let!(:spinning_room) { create(:room, name: 'Spinning room') }

  background do
    login_as(admin, scope: :user)
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

    click_link 'Add'
    attach_file 'room_photo[photo]', Rails.root.join('spec', 'support', 'images', 'room.jpg')
    find( '.new_room_photo').click_button 'Save'

    expect(page).to have_selector('.admin-gallery img')

    find('.admin-gallery').click_link 'Delete'
    page.driver.browser.switch_to.alert.accept

    expect(page).not_to have_selector('.admin-gallery img')
  end
end