require 'rails_helper'

RSpec.feature 'user checks their reservations', js: true do
  let!(:user) { create(:user) }
  let!(:active_reservation) { create(:reservation, user: user) }
  let!(:queued_reservation) { create(:queued_reservation, user: user) }
  let!(:attended_reservation) { create(:reservation, user: user, status: 'attended') }
  let!(:missed_reservation) { create(:reservation, user: user, status: 'missed') }

  background do
    login_as(user, scope: :user)
    visit root_path
    click_link user.email
    click_link 'My Reservations'
  end

  scenario do
    expect(page).to have_content 'Current reservations'
    expect(page).to have_content 'Waiting list'
    expect(page).to have_content 'Past reservations'
    expect(page).to have_content 'Missed reservations'

    expect(page).to have_content active_reservation.schedule_item
    expect(page).not_to have_content queued_reservation.schedule_item
    expect(page).not_to have_content attended_reservation.schedule_item
    expect(page).not_to have_content missed_reservation.schedule_item
    expect(page).to have_link 'Cancel'

    click_link 'Waiting list'

    expect(page).not_to have_content active_reservation.schedule_item
    expect(page).to have_content queued_reservation.schedule_item
    expect(page).not_to have_content attended_reservation.schedule_item
    expect(page).not_to have_content missed_reservation.schedule_item
    expect(page).to have_link 'Cancel'

    click_link 'Past reservations'

    expect(page).not_to have_content active_reservation.schedule_item
    expect(page).not_to have_content queued_reservation.schedule_item
    expect(page).to have_content attended_reservation.schedule_item
    expect(page).not_to have_content missed_reservation.schedule_item
    expect(page).not_to have_link 'Cancel'

    click_link 'Missed reservations'

    expect(page).not_to have_content active_reservation.schedule_item
    expect(page).not_to have_content queued_reservation.schedule_item
    expect(page).not_to have_content attended_reservation.schedule_item
    expect(page).to have_content missed_reservation.schedule_item
    expect(page).not_to have_link 'Cancel'

  end

end