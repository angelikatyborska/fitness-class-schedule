require 'rails_helper'

feature 'User check schedules for rooms', js: true do
  let!(:small_room) { create(:room, name: 'Small room') }
  let!(:big_room) { create(:room, name: 'Big room') }
  let!(:small_schedule_item_this_monday) do
    create(
      :schedule_item,
      room: small_room,
      start: Time.zone.now.in_website_time_zone.beginning_of_week + 8.hours + 5.minutes,
      capacity: 6
    )
  end

  let!(:small_schedule_item_next_monday) do
    create(
      :schedule_item,
      room: small_room,
      start: Time.zone.now.in_website_time_zone.beginning_of_week + 1.week + 8.hours + 15.minutes,
      capacity: 6 )
  end

  let!(:big_schedule_item_this_sunday) {
    create(
      :schedule_item,
      room: big_room,
      start: Time.zone.now.in_website_time_zone.beginning_of_week + 6.days + 9.hours + 5.minutes,
      capacity: 20
    )
  }

  let!(:big_schedule_item_next_sunday) do
    create(
      :schedule_item,
      room: big_room,
      start: Time.zone.now.in_website_time_zone.beginning_of_week + 1.week + 6.days + 9.hours + 15.minutes,
      capacity: 20
    )
  end

  before :all do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  context 'at the beginning of the week' do
    scenario 'all rooms' do
      visit root_path
      expect(page).to have_link small_schedule_item_this_monday
      expect(page).to have_content '8:05'
      expect(page).to have_link big_schedule_item_this_sunday
      expect(page).to have_content '9:05'

      click_link 'Next week'
      wait_for_ajax

      expect(page).to have_link small_schedule_item_next_monday
      expect(page).to have_content '8:15'
      expect(page).to have_link big_schedule_item_next_sunday
      expect(page).to have_content '9:15'
    end

    scenario 'the small room' do
      visit root_path
      click_button 'Location'
      click_link 'Small room'

      expect(page).to have_link small_schedule_item_this_monday
      expect(page).to have_content '8:05'

      expect(page).not_to have_content big_schedule_item_this_sunday
      expect(page).not_to have_content '9:05'

      click_link 'Next week'
      wait_for_ajax

      expect(page).to have_link small_schedule_item_next_monday
      expect(page).to have_content '8:15'
      expect(page).not_to have_content big_schedule_item_next_sunday
      expect(page).not_to have_content '9:15'
    end

    scenario 'the big room' do
      visit root_path
      click_button 'Location'
      click_link 'Big room'

      expect(page).not_to have_content small_schedule_item_this_monday
      expect(page).not_to have_content '8:05'

      expect(page).to have_link big_schedule_item_this_sunday
      expect(page).to have_content '9:05'

      click_link 'Next week'
      wait_for_ajax

      expect(page).not_to have_content small_schedule_item_next_monday
      expect(page).not_to have_content '8:15'
      expect(page).to have_link big_schedule_item_next_sunday
      expect(page).to have_content '9:15'
    end
  end

  context 'on a wednesday' do
    scenario 'all rooms' do
      Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week + 3.days)
      visit root_path
      expect(page).to have_content small_schedule_item_this_monday
      expect(page).to have_no_link small_schedule_item_this_monday
      expect(page).to have_link big_schedule_item_this_sunday
    end
  end
end
