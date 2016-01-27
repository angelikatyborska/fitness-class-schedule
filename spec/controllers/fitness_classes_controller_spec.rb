require 'rails_helper'

RSpec.describe FitnessClassesController do
  describe 'GET #index' do
    let!(:fitness_classes) { create_list :fitness_class, 3 }

    subject { get :index }

    it { is_expected.to render_template :index }
    it { is_expected.to expose :fitness_classes, fitness_classes }
  end
end