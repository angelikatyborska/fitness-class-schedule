require 'rails_helper'

feature 'User deletes a reservation', js: true do
  let!(:schedule_item) { create(:schedule_item_this_week, activity: 'ABT') }
  let!(:user) { create(:user) }
  let!(:reservation) { create(:reservation, user: user, schedule_item: schedule_item) }

  before :all do
    Timecop.freeze(Time.zone.now.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  scenario 'via user panel' do
    log_in user
    visit root_path
    click_link user.email
    click_link 'Reservations'
    expect(page).to have_link 'Cancel'
    expect {
      click_link 'Cancel'
      wait_for_ajax
    }.to change(user.reservations, :count).by(-1)
    expect(page).to have_content 'Your reservation has been deleted.'
  end

  scenario 'via schedule item dialog box' do
    log_in user
    visit root_path
    click_link schedule_item.activity
    expect(page).to have_link 'Cancel'
    expect {
      click_link 'Cancel'
      wait_for_ajax
    }.to change(user.reservations, :count).by(-1)
    expect(page).to have_content 'Your reservation has been deleted.'
  end
end