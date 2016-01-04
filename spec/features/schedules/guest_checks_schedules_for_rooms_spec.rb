require 'rails_helper'

feature 'Guest check schedules for rooms' do
  let!(:small_room) { create(:room, name: 'Small room') }
  let!(:big_room) { create(:room, name: 'Big room') }
  let!(:small_schedule_item_this_week) {
    create(:schedule_item, room: small_room, activity: 'ABT', start: Time.zone.parse('8:05'), capacity: 6 )
  }
  let!(:small_schedule_item_next_week) {
    create(:schedule_item, room: small_room, activity: 'Step', start: Time.zone.parse('8:15') + 7.days, capacity: 6 )
  }
  let!(:big_schedule_item_this_week) {
    create(:schedule_item, room: big_room, activity: 'TBC', start: Time.zone.parse('9:05'), capacity: 20)
  }
  let!(:big_schedule_item_next_week) {
    create(:schedule_item, room: big_room, activity: 'Step', start: Time.zone.parse('9:15') + 7.days, capacity: 20)
  }

  before :all do
    Timecop.freeze(Time.zone.now.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  scenario 'all rooms' do
    visit root_path
    expect(page).to have_content 'ABT'
    expect(page).to have_content '8:05'
    expect(page).to have_content 'TBC'
    expect(page).to have_content '9:05'

    click_link 'Next week'

    expect(page).to have_content 'Step'
    expect(page).to have_content '8:15'
    expect(page).to have_content '9:15'
  end

  scenario 'the small room' do
    visit root_path
    click_link 'Rooms'
    click_link 'Small room'

    expect(page).to have_content 'ABT'
    expect(page).to have_content '8:05'

    expect(page).not_to have_content 'TBC'
    expect(page).not_to have_content '9:05'

    click_link 'Next week'

    expect(page).to have_content 'Step'
    expect(page).to have_content '8:15'
    expect(page).not_to have_content '9:15'
  end

  scenario 'the big room' do
    visit root_path
    click_link 'Rooms'
    click_link 'Big room'

    expect(page).not_to have_content 'ABT'
    expect(page).not_to have_content '8:05'

    expect(page).to have_content 'TBC'
    expect(page).to have_content '9:05'

    click_link 'Next week'

    expect(page).to have_content 'Step'
    expect(page).not_to have_content '8:15'
    expect(page).to have_content '9:15'
  end

  scenario 'all rooms in the future' do
    Timecop.freeze(Time.zone.now.end_of_week) do
      visit root_path
      expect(page).to have_content 'ABT'
      expect(page).to have_no_link 'ABT'
    end
  end
end