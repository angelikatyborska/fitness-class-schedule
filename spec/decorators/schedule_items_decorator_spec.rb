RSpec.describe ScheduleItemDecorator do
  let!(:today) { Time.zone.now.middle_of_day }
  let(:schedule_item) { build(:schedule_item, start: today, duration: 45)}

  describe '#stop' do
    subject { schedule_item.decorate.stop }
    it { is_expected.to eq today + 45.minutes }
  end

  describe '#start_day_percentage' do
    context 'starts at the beginning of the day' do
      let(:schedule_item_beginning) { build(:schedule_item, start: ScheduleItem.beginning_of_day(today))}

      subject { schedule_item_beginning.decorate.start_day_percentage }
      it { is_expected.to be_within(1).of(0) }
    end

    context 'starts in the middle of the day' do
      let(:schedule_item_middle) { build(:schedule_item, start: ScheduleItem.beginning_of_day(today) + (ScheduleItem.day_duration_in_quarters * 15 / 2).minutes) }

      subject { schedule_item_middle.decorate.start_day_percentage }
      it { is_expected.to be_within(1).of(50) }
    end

    context 'starts at the end of the day' do
      let(:schedule_item_end) { build(:schedule_item, start: ScheduleItem.end_of_day(today) - 1.hour)}

      subject { schedule_item_end.decorate.start_day_percentage }
      it { is_expected.to be_within(1).of(100 - (100 * 4 / ScheduleItem.day_duration_in_quarters)) }
    end
  end

  describe '#duration_day_percentage' do
    context 'is 1 hour long' do
      let(:one_hour_schedule_item) { build(:schedule_item, start: ScheduleItem.beginning_of_day(today), duration: 60)}

      subject { one_hour_schedule_item.decorate.duration_day_percentage }
      it { is_expected.to be_within(1).of((100 * 4 / ScheduleItem.day_duration_in_quarters)) }
    end

    context 'is all day long' do
      let(:twenty_three_hour_schedule_item) { build(:schedule_item, start: ScheduleItem.beginning_of_day(today), duration: ScheduleItem.day_duration_in_quarters * 15) }

      subject { twenty_three_hour_schedule_item.decorate.duration_day_percentage }
      it { is_expected.to be_within(1).of(100) }
    end
  end
end