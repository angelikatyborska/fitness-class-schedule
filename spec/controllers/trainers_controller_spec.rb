require 'rails_helper'

RSpec.describe TrainersController do
  describe 'GET #index' do
    let!(:trainers) { create_list :trainer, 3 }

    subject { get :index }

    it { is_expected.to render_template :index }
    it { is_expected.to expose :trainers, trainers }
  end
end