require 'rails_helper'

RSpec.describe RoomsController do
  describe 'GET #index' do
    let!(:rooms) { create_list(:room, 3) }
    subject { get :index }

    it 'renders template index' do
      is_expected.to render_template :index
    end

    it 'exposes rooms' do
      expect(controller.rooms).to eq rooms
    end
  end
end