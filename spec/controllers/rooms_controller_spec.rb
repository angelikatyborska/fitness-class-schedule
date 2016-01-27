require 'rails_helper'

RSpec.describe RoomsController do
  describe 'GET #index' do
    let!(:rooms) { create_list :room, 3 }

    subject { get :index }

    it { is_expected.to render_template :index }
    it { is_expected.to expose :rooms, rooms }
  end
end