require 'rails_helper'

feature 'Admin creates a fitness class' do
  let!(:admin) { create :admin_user }
  let!(:step) { create :fitness_class, name: 'Step' }

  background do
    login_as admin, scope: :user

    visit root_path
    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Classes'
    click_link 'Add'
  end

  scenario 'with valid input' do
    expect {
      fill_in 'Name', with: 'ABT'
      fill_in 'Description', with: 'Abs, buttocks and tights. Shape up your body! Great for beginner.'
      fill_in 'Color', with: '#dddddd'
      click_button 'Save'
    }.to change(FitnessClass, :count).by(1)

    expect(page).to have_content 'ABT'
  end

  scenario 'with invalid input' do
    fill_in 'Name', with: 'Step'
    fill_in 'Color', with: '#dddddd'
    click_button 'Save'
    expect(page).to have_content 'has already been taken'
    expect(page).to have_content 'can\'t be blank'
  end
end