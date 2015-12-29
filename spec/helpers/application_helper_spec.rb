RSpec.describe ApplicationHelper do
  describe '#schedule_item_width' do
    context 'with 3 schedule items going on at the same time' do
      let(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now + 1.day)}
      let!(:schedule_items) do
        3.times.with_object([]) do |n, items|
          items << build(:schedule_item, start: tomorrow)
        end
      end

      subject { schedule_item_width(schedule_items[0], schedule_items) }

      it { is_expected.to be_within(0.1).of(33.33) }
    end

    context 'with 3 schedule items going on at different times' do
      let(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now + 1.day)}
      let!(:schedule_items) do
        3.times.with_object([]) do |n, items|
          items << build(:schedule_item, start: tomorrow + n.days)
        end
      end

      subject { schedule_item_width(schedule_items[0], schedule_items) }

      it { is_expected.to be_within(0.1).of(100) }
    end
  end

  describe '#schedule_item_left_position' do
    context 'with 3 schedule items going on at the same time' do
      let(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now + 1.day)}
      let!(:schedule_items) do
        3.times.with_object([]) do |n, items|
          items << build(:schedule_item, start: tomorrow)
        end
      end

      it { expect(schedule_item_left_position(schedule_items[0], schedule_items)).to be_within(0.1).of(0) }
      it { expect(schedule_item_left_position(schedule_items[1], schedule_items)).to be_within(0.1).of(33.33) }
      it { expect(schedule_item_left_position(schedule_items[2], schedule_items)).to be_within(0.1).of(66.66) }
    end

    context 'with 3 schedule items going on at different times' do
      let(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now + 1.day)}
      let!(:schedule_items) do
        3.times.with_object([]) do |n, items|
          items << build(:schedule_item, start: tomorrow + n.days)
        end
      end

      it { expect(schedule_item_left_position(schedule_items[0], schedule_items)).to be_within(0.1).of(0) }
      it { expect(schedule_item_left_position(schedule_items[1], schedule_items)).to be_within(0.1).of(0) }
      it { expect(schedule_item_left_position(schedule_items[2], schedule_items)).to be_within(0.1).of(0) }
    end
  end
end