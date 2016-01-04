require 'rails_helper'

RSpec.describe ScheduleItemsController do
  describe 'GET #index' do
    let(:room) { create(:room) }
    #TODO: refactor to use Timecop
    let!(:schedule_item_this_week) {
      item = build(:schedule_item_this_week, room: room)
      item.save(validate: false)
      item
    }

    let!(:schedule_item_next_week) {
      item = build(:schedule_item_next_week, room: room)
      item.save(validate: false)
      item
    }

    subject { get :index, room_id: room }

    it { is_expected.to render_template :index }

    context 'without parameters' do
      it 'exposes schedule items from this week' do
        get :index, room_id: room
        expect(controller.schedule_items).to eq([schedule_item_this_week])
      end
    end

    context 'with next week as parameter' do
      let!(:next_week) { Time.zone.now + 7.days }

      it 'exposes next week' do
        get :index, room_id: room, week: next_week
        expect(controller.week).to be_within(1.minute).of(next_week)
      end

      it 'exposes schedule items from next week' do
        get :index, room_id: room, week: next_week
        expect(controller.schedule_items).to eq([schedule_item_next_week])
      end
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