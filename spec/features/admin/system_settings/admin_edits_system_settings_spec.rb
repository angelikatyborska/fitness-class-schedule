require'rails_helper'

feature 'admin edits system setting' do
  let!(:admin) { create(:admin_user) }

  background do
    login_as(admin, scope: :user)
  end

  scenario 'checks settings' do
    visit root_path
    click_link 'Admin Panel'
    click_link 'Site Settings'
    expect(page).to have_content 'Day starts'
    expect(page).to have_content 'Day ends'
    expect(page).to have_content 'Site title'
    expect(page).to have_content 'Schedule time zone'
  end

  scenario 'edits site title' do
    visit root_path
    click_link 'Admin Panel'
    click_link 'Site Settings'
    fill_in 'Site title', with: 'My Awesome Site'
    click_button 'Save'
    visit root_path

    within 'nav' do
      expect(page).to have_content 'My Awesome Site'
    end
  end

  context 'with a schedule item' do
    let!(:schedule_item) { create(:schedule_item, start: Time.now.utc.beginning_of_day +  12.hours ) }

    before :all do
      Timecop.freeze(Time.now.utc.beginning_of_day)
    end

    after :all do
      Timecop.return
    end

    scenario 'edits schedule time zone' do
      visit root_path
      click_link 'Admin Panel'
      click_link 'Site Settings'
      select '0', from: 'Day starts'
      select '23', from: 'Day ends'
      select 'UTC', from: 'Schedule time zone'
      click_button 'Save'

      visit root_path
      within '.schedule' do
        expect(page).to have_content '12:00'
      end

      click_link 'Admin Panel'
      click_link 'Site Settings'
      select 'Hawaii', from: 'Schedule time zone'
      click_button 'Save'

      visit root_path
      within '.schedule' do
        expect(page).to have_content '02:00'
      end
    end

    scenario 'edits day start so that it\'s later than day end' do
      visit root_path
      click_link 'Admin Panel'
      click_link 'Site Settings'
      select '0', from: 'Day starts'
      select '23', from: 'Day ends'
      select 'UTC', from: 'Schedule time zone'
      click_button 'Save'

      visit root_path
      within '.schedule' do
        expect(page).to have_content '12:00'
      end

      click_link 'Admin Panel'
      click_link 'Site Settings'
      select '23', from: 'Day starts'
      select '15', from: 'Day ends'
      click_button 'Save'

      visit root_path
      within '.schedule' do
        expect(page).not_to have_content '12:00'
      end
    end
  end
end