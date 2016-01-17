require 'rails_helper'

RSpec.describe ScheduleItemsController do
  describe 'GET #index' do
    let!(:zumba_instructor) { create(:trainer) }
    let!(:spinning_instructor) { create(:trainer) }

    let!(:zumba_room) { create(:room) }
    let!(:spinning_room) { create(:room) }

    let!(:zumba_this_week) { create(
      :schedule_item_this_week_in_website_time_zone,
      trainer: zumba_instructor,
      room: zumba_room
    ) }

    let!(:zumba_next_week) { create(
      :schedule_item_next_week_in_website_time_zone,
      trainer: zumba_instructor,
      room: zumba_room
    ) }

    let!(:spinning_this_week) { create(
      :schedule_item_this_week_in_website_time_zone,
      trainer: spinning_instructor,
      room: spinning_room
    ) }

    let!(:spinning_next_week) { create(
      :schedule_item_next_week_in_website_time_zone,
      trainer: spinning_instructor,
      room: spinning_room
    ) }

    before :all do
      Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
    end

    after :all do
      Timecop.return
    end

    context 'without params' do
      subject { get :index }

      it { is_expected.to render_template :index }

      it 'exposes schedule items' do
        get :index
        expect(controller.schedule_items) =~ [zumba_this_week, spinning_this_week]
      end
    end

    context 'with week offset' do
      subject { get :index, week_offset: 1 }

      it { is_expected.to render_template :index }

      it 'exposes schedule items' do
        get :index, week_offset: 1
        expect(controller.schedule_items) =~ [zumba_next_week, spinning_next_week]
      end
    end

    context 'with trainer' do
      subject { get :index, trainer_id: zumba_instructor.id }

      it { is_expected.to render_template :index }

      it 'exposes schedule items' do
        get :index, trainer_id: zumba_instructor.id
        expect(controller.schedule_items) =~ [zumba_this_week, zumba_next_week]
      end
    end

    context 'with room' do
      subject { get :index, room_id: zumba_room.id }

      it { is_expected.to render_template :index }

      it 'exposes schedule items' do
        get :index, room_id: zumba_room.id
        expect(controller.schedule_items) =~ [zumba_this_week, zumba_next_week]
      end
    end
  end

  describe 'GET #show' do
    let(:schedule_item) { create(:schedule_item) }

    subject { get :show, id: schedule_item }

    it { is_expected.to render_template :show }

    it 'exposes the requested schedule item' do
      get :show, id: schedule_item
      expect(controller.schedule_item).to eq schedule_item
    end
  end
end