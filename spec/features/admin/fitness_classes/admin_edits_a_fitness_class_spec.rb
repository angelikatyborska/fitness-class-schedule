require 'rails_helper'

feature 'Admin creates a fitness class' do
  let!(:admin) { create(:admin_user) }
  let!(:step) { create(:fitness_class, name: 'Step') }

  background do
    login_as(admin, scope: :user)

    visit root_path
    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Classes'
  end

  scenario 'with valid input' do
    expect(page).to have_content 'Step'
    expect(page).not_to have_content 'ABT'

    click_link 'Edit'
    fill_in 'Name', with: 'ABT'
    click_button 'Save'

    expect(page).not_to have_content 'Step'
    expect(page).to have_content 'ABT'
  end
end