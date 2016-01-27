require 'rails_helper'

feature 'User makes a reservation', js: true do
  before :each do
    Timecop.travel(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :each do
    Timecop.return
  end

  context 'without logging in' do
    let!(:schedule_item) { create :schedule_item_this_week_in_website_time_zone, capacity: 1 }

    scenario 'there is no \'Reserve\' button' do
      visit root_path
      click_link schedule_item
      expect(page).to have_button 'Close'
      expect(page).not_to have_content 'Reserve'
    end
  end

  context 'with logging in' do
    let!(:user) { create :user }
    let!(:schedule_item) { create :schedule_item_this_week_in_website_time_zone, capacity: 1 }

    background do
      login_as user, scope: :user
    end

    context 'when there are empty spots' do
      scenario 'adds reservation' do
        visit root_path
        click_link schedule_item
        expect(page).to have_selector("input[type=submit][value='Reserve']")
        expect {
          click_button 'Reserve'
          wait_for_ajax
        }.to change(user.reservations, :count).by(1)

        expect(page).to have_content 'Your reservation has been added.'

        click_button 'Close'
        expect(page).not_to have_button 'Close'

        click_link schedule_item
        expect(page).to have_content 'Cancel'
        expect(page).not_to have_content 'Waiting list position:'
      end
    end

    context 'when there are no empty spots' do
      let!(:other_reservation) { create :reservation, schedule_item: schedule_item }

      scenario 'adds to waiting list' do
        visit root_path
        click_link schedule_item

        expect(page).to have_selector("input[type=submit][value='Add to waiting list']")
        expect {
          click_button 'Add to waiting list'
          wait_for_ajax
        }.to change(user.reservations, :count).by(1)

        expect(page).to have_content 'Your reservation has been added.'

        click_button 'Close'
        expect(page).not_to have_button 'Close'

        click_link schedule_item

        expect(page).to have_content 'Waiting list position:'

        expect(page).to have_button 'Close'
        click_button 'Close'
        expect(page).not_to have_button 'Close'
      end
    end
  end
end