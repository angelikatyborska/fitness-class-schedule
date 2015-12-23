RSpec.describe ScheduleItemsController do
  describe 'GET #index' do
    before :all do
      @room = create(:room)
      @schedule_item_this_week = build(:schedule_item_this_week, room: @room)
      @schedule_item_this_week.save(validate: false)
      @schedule_item_next_week = build(:schedule_item_next_week, room: @room)
      @schedule_item_next_week.save(validate: false)
    end

    subject { get :index, room_id: @room }

    it { is_expected.to render_template :index }

    context 'without parameters' do
      it 'exposes schedule items from this week' do
        get :index, room_id: @room
        expect(controller.schedule_items).to eq([@schedule_item_this_week])
      end
    end

    context 'with next week as parameter' do
      before :all do
        @next_week = Time.zone.now + 7.days
      end

      it 'exposes next week' do
        get :index, room_id: @room, week: @next_week
        expect(controller.week).to be_within(1.minute).of(@next_week)
      end

      it 'exposes schedule items from next week' do
        get :index, room_id: @room, week: @next_week
        expect(controller.schedule_items).to eq([@schedule_item_next_week])
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