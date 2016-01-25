require 'rails_helper'

feature 'Guest checks rooms' do
  let!(:big_room) { create :room, name: 'Big room' }
  let!(:small_room) { create :room, name: 'Small room' }

  let!(:big_room_photos) { create_list :room_photo, 2, room: big_room }
  let!(:small_room_photos) { create_list :room_photo, 2, room: small_room }

  scenario do
    visit root_path
    click_link 'Locations'

    [big_room, small_room].each do |room|
      expect(page).to have_content room.name
      expect(page).to have_content room.description
      expect(page).to have_link 'Check out the schedule for this location'

      room.room_photos.each do |photo|
        expect(page).to have_selector("img[src='#{ photo.photo.thumb.url }']")
        expect(page).to have_selector("a[href='#{ photo.photo.url }']")
      end
    end
  end
end