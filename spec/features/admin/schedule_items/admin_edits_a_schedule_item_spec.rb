require 'rails_helper'

feature 'Admin edits a schedule item' do
  let!(:abt) { create(:fitness_class, name: 'ABT') }
  let!(:tbc) { create(:fitness_class, name: 'TBC') }
  let!(:schedule_item) { create(:schedule_item, fitness_class: abt) }
  let!(:admin) { create(:admin_user) }

  background do
    login_as(admin, scope: :user)
  end

  scenario 'with valid input' do
    visit root_path

    click_link 'Admin panel'
    click_link 'Schedule items'

    expect(page).to have_content 'ABT'

    click_link 'Edit'

    expect {
      select 'TBC', from: 'Fitness class'
      click_button 'Save'
    }.to change(ScheduleItem, :count).by(0)

    expect(current_path).to eq admin_schedule_items_path

    expect(page).not_to have_content 'ABT'
    expect(page).to have_content 'TBC'
  end
end