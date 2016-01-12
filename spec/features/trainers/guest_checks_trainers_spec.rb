require 'rails_helper'

feature 'guest checks trainers' do
  let!(:ann) { create(:trainer, first_name: 'Ann') }
  let!(:paul) { create(:trainer, first_name: 'Paul') }

  scenario do
    visit root_path
    click_link 'Trainers'

    expect(page).to have_content 'Ann'
    expect(page).to have_content ann.description
    page.should have_xpath("//img[@src='#{ ann.photo.url }']")

    expect(page).to have_content 'Paul'
    expect(page).to have_content paul.description
    page.should have_xpath("//img[@src='#{ paul.photo.url }']")
  end
end