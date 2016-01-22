require 'rails_helper'

feature 'guest checks classes' do
  let!(:fitness_classes) { create_list(:fitness_class, 3) }

  scenario do
    visit root_path
    click_link 'Classes'

    fitness_classes.each do |fitness_class|
      expect(page).to have_content fitness_class.name
      expect(page).to have_content fitness_class.description
    end
  end
end