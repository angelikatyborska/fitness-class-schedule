require 'rails_helper'

feature 'User makes a reservation', js: true do
  let!(:schedule_item) { create(:schedule_item_this_week_in_website_time_zone, capacity: 1) }
  let!(:user) { create(:user) }

  before :all do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  scenario 'without logging in' do
    visit root_path
    click_link schedule_item
    expect(page).not_to have_content 'Reserve'
  end

  context 'with logging in' do
    context 'when there are empty spots' do
      scenario 'adds reservation' do
        login_as(user, scope: :user)
        visit root_path
        click_link schedule_item
        expect(page).to have_selector("input[type=submit][value='Reserve']")
        expect {
          click_button 'Reserve'
          wait_for_ajax
        }.to change(user.reservations, :count).by(1)
        expect(page).to have_content 'Your reservation has been added.'
      end
    end

    context 'when there are no empty spots' do
      let!(:other_reservation) { create(:reservation, schedule_item: schedule_item) }

      scenario 'adds to waiting list' do
        login_as(user, scope: :user)
        visit root_path
        click_link schedule_item
        expect(page).to have_selector("input[type=submit][value='Add to waiting list']")
        expect {
          click_button 'Add to waiting list'
          wait_for_ajax
        }.to change(user.reservations, :count).by(1)
        expect(page).to have_content 'Your reservation has been added.'
      end
    end
  end
end