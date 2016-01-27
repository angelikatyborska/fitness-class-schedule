require 'rails_helper'

RSpec.feature 'Admin deletes a reservation', js: true do
  let!(:admin) { create :admin_user }
  let!(:user) { create :user }
  let!(:reservation) { create :reservation, user: user }

  background do
    login_as admin, scope: :user

    visit root_path
    click_link 'Admin Panel'
    click_link 'Users'
  end

  scenario do
    expect(page).to have_content user.last_name
    expect(page).to have_content user.email
    find('#' + user.decorate.css_id).click_link 'Show'
    expect(page).to have_content reservation.schedule_item
    expect {
      click_link 'Cancel'
      expect(page).to have_content 'Reservation has been deleted!'
    }.to change(Reservation, :count).by(-1)
  end
end