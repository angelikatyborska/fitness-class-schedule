RSpec.describe ApplicationHelper do
  describe '#schedule_item_width' do
    context 'with 3 schedule items going on at the same time' do
      let(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now.in_website_time_zone + 1.day)}
      let!(:schedule_items) do
        3.times.with_object([]) do |n, items|
          items << build(:schedule_item, start: tomorrow)
        end
      end

      subject { schedule_item_width(schedule_items[0], schedule_items) }

      it { is_expected.to be_within(0.1).of(33.33) }
    end

    context 'with 3 schedule items going on at different times' do
      let(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now.in_website_time_zone + 1.day)}
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
      let(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now.in_website_time_zone + 1.day)}
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
      let(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now.in_website_time_zone + 1.day)}
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

  describe '#start_day_percentage' do
    let!(:today) { Time.zone.now.in_website_time_zone.middle_of_day }
    let(:schedule_item) { build(:schedule_item, start: today, duration: 45)}

    context 'starts at the beginning of the day' do
      let(:schedule_item_beginning) { build(:schedule_item, start: ScheduleItem.beginning_of_day(today))}

      subject { schedule_item_start_day_percentage(schedule_item_beginning) }
      it {
        is_expected.to be_within(1).of(0)
      }
    end

    context 'starts in the middle of the day' do
      let(:schedule_item_middle) { build(:schedule_item, start: ScheduleItem.beginning_of_day(today) + (ScheduleItem.day_duration_in_quarters * 15 / 2).minutes) }

      subject { schedule_item_start_day_percentage(schedule_item_middle) }
      it { is_expected.to be_within(1).of(50) }
    end

    context 'starts at the end of the day' do
      let(:schedule_item_end) { build(:schedule_item, start: ScheduleItem.end_of_day(today) - 1.hour)}

      subject { schedule_item_start_day_percentage(schedule_item_end) }
      it { is_expected.to be_within(1).of(100 - (100 * 4 / ScheduleItem.day_duration_in_quarters)) }
    end
  end

  describe '#duration_day_percentage' do
    let!(:today) { Time.zone.now.in_website_time_zone.middle_of_day }
    let(:schedule_item) { build(:schedule_item, start: today, duration: 45)}

    context 'is 1 hour long' do
      let(:one_hour_schedule_item) { build(:schedule_item, start: ScheduleItem.beginning_of_day(today), duration: 60)}

      subject { schedule_item_duration_day_percentage(one_hour_schedule_item) }
      it { is_expected.to be_within(1).of((100 * 4 / ScheduleItem.day_duration_in_quarters)) }
    end

    context 'is all day long' do
      let(:twenty_three_hour_schedule_item) { build(:schedule_item, start: ScheduleItem.beginning_of_day(today), duration: ScheduleItem.day_duration_in_quarters * 15) }

      subject { schedule_item_duration_day_percentage(twenty_three_hour_schedule_item) }
      it { is_expected.to be_within(1).of(100) }
    end
  end
end