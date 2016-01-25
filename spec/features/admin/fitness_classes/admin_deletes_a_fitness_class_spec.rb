require 'rails_helper'

feature 'Admin deletes a fitness class', js: true do
  let!(:fitness_class) { create :fitness_class }
  let!(:admin) { create :admin_user }

  background do
    login_as(admin, scope: :user)
  end

  scenario do
    visit root_path

    click_link 'Admin Panel'
    find('.admin-panel').click_link 'Classes'

    expect(page).to have_content fitness_class
    expect(page).to have_content fitness_class.description

    expect {
      click_link 'Delete'
      wait_for_ajax
    }.to change(FitnessClass, :count).by(-1)

    expect(current_path).to eq admin_fitness_classes_path

    expect(page).not_to have_content fitness_class
    expect(page).not_to have_content fitness_class.description
  end
end