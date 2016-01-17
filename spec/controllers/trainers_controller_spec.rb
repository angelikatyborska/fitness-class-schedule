require 'rails_helper'

RSpec.describe TrainersController do
  describe 'GET #index' do
    let!(:trainers) { create_list(:trainer, 3) }
    subject { get :index }

    it 'renders template index' do
      is_expected.to render_template :index
    end

    it 'exposes trainers' do
      expect(controller.trainers).to match_array trainers
    end
  end
end