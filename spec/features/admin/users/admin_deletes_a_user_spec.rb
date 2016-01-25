require 'rails_helper'

feature 'Admin deletes a user' do
  let!(:user) { create :user }
  let!(:admin) { create :admin_user }

  background do
    login_as admin, scope: :user
  end

  scenario do
    visit root_path

    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Users'

    expect(page).to have_content user.last_name
    expect(page).to have_content user.email

    expect {
      find("##{ user.decorate.css_id }").click_link 'Delete'
    }.to change(User, :count).by(-1)

    expect(current_path).to eq admin_users_path

    expect(page).not_to have_content user.last_name
    expect(page).not_to have_content user.email
  end
end