require 'rails_helper'

RSpec.describe FitnessClassesController do
  describe 'GET #index' do
    let!(:fitness_classes) { create_list(:fitness_class, 3) }
    subject { get :index }

    it 'renders template index' do
      is_expected.to render_template :index
    end

    it 'exposes fitness classes' do
      expect(controller.fitness_classes).to eq fitness_classes
    end
  end
end