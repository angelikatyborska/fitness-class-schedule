require 'rails_helper'

RSpec.describe ScheduleItemsController do
  before :all do
    Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
  end

  after :all do
    Timecop.return
  end

  describe 'GET #index' do
    let!(:zumba_instructor) { create :trainer }
    let!(:spinning_instructor) { create :trainer }

    let!(:zumba_room) { create :room }
    let!(:spinning_room) { create :room }

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

    context 'without params' do
      subject { get :index }

      it { is_expected.to render_template :index }
      it { is_expected.to expose :schedule_items, [zumba_this_week, spinning_this_week] }
    end

    context 'with week offset' do
      subject { get :index, week_offset: 1 }

      it { is_expected.to render_template :index }
      it { is_expected.to expose :schedule_items, [zumba_next_week, spinning_next_week] }
    end

    context 'with trainer' do
      subject { get :index, trainer: zumba_instructor.id }

      it { is_expected.to render_template :index }
      it { is_expected.to expose :schedule_items, [zumba_this_week] }
    end

    context 'with room' do
      subject { get :index, room: zumba_room.id }

      it { is_expected.to render_template :index }
      it { is_expected.to expose :schedule_items, [zumba_this_week] }
    end

    context 'with room and week offset' do
      subject { get :index, room: zumba_room.id, week_offset: 1 }

      it { is_expected.to render_template :index }
      it { is_expected.to expose :schedule_items, [zumba_next_week] }
    end
  end

  describe 'GET #show' do
    let!(:schedule_item) { create :schedule_item }

    subject { get :show, id: schedule_item }

    it { is_expected.to render_template :show }
    it { is_expected.to expose :schedule_item, schedule_item }
  end

  describe 'GET #focus' do
    before :all do
      Timecop.freeze(Time.zone.now.in_website_time_zone.beginning_of_week)
    end

    after :all do
      Timecop.return
    end

    context 'with a schedule item this week' do
      let!(:schedule_item) { create :schedule_item_this_week_in_website_time_zone }

      subject { get :focus, id: schedule_item }

      it 'redirects to index with an anchor and proper week offset' do
        is_expected.to redirect_to action: :index, week_offset: 0
        expect(controller).to set_flash[:focus].to schedule_item.decorate.css_id
      end
    end

    context 'with a schedule item next week' do
      let!(:schedule_item) { create :schedule_item_next_week_in_website_time_zone }

      subject { get :focus, id: schedule_item }

      it 'redirects to index with an anchor and proper week offset' do
        is_expected.to redirect_to action: :index, week_offset: 1
        expect(controller).to set_flash[:focus].to schedule_item.decorate.css_id
      end
    end
  end
end
