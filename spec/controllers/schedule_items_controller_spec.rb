require 'rails_helper'

RSpec.describe ScheduleItemsController do
  describe 'GET #index' do
    let(:room) { create(:room) }
    let!(:schedule_items) { create_list(:schedule_item, 3, room: room) }

    before :all do
      Timecop.freeze(Time.zone.now.beginning_of_week)
    end

    after :all do
      Timecop.return
    end

    subject { get :index, room_id: room }

    it { is_expected.to render_template :index }

    it 'exposes schedule items' do
      get :index, room_id: room
      expect(controller.schedule_items).to contain_exactly(*schedule_items)
    end
  end

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