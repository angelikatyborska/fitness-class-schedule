require 'rails_helper'

RSpec.describe ScheduleItemsController do
  describe 'GET #show' do
    let(:room) { create(:room) }
    let(:schedule_item) { create(:schedule_item, room: room) }

    subject { get :show, id: schedule_item, room_id: room }

    it { is_expected.to render_template :show }

    it 'exposes the requested schedule item' do
      get :show, id: schedule_item, room_id: room
      expect(controller.schedule_item).to eq schedule_item
    end
  end
end