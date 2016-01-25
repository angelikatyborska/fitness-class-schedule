RSpec.describe ApplicationHelper do
  describe '#order_by_weekdays' do
    let!(:monday) { Time.zone.now.in_website_time_zone.beginning_of_week + 1.week }
    let!(:schedule_item_next_monday) { create :schedule_item, start: monday }
    let!(:schedule_item_next_tuesday) { create :schedule_item, start: monday + 1.day }

    subject { order_by_weekdays(ScheduleItem.all, 1)}

    it 'returns a hash with days as keys and arrays of schedule items as values' do
      is_expected.to eq({
                          monday => [schedule_item_next_monday],
                          (monday + 1.day) => [schedule_item_next_tuesday],
                          (monday + 2.days) => [],
                          (monday + 3.days) => [],
                          (monday + 4.days) => [],
                          (monday + 5.days) => [],
                          (monday + 6.days) => []
                        })
    end
  end

  describe '#schedule_items_styles' do
    describe '#for' do
      let(:schedule_item) { build :schedule_item }
      let(:styles) { schedule_items_styles([schedule_item]) }

      subject { styles.for(schedule_item) }

      it 'returns a string css styles for a schedule item' do
        is_expected.to match /top:\s?-?[\d\.]*%;/
        is_expected.to match /left:\s?-?[\d\.]*%;/
        is_expected.to match /width:\s?-?[\d\.]*%;/
        is_expected.to match /height:\s?-?[\d\.]*%;/
      end
    end

    describe '#left and #width' do
      context '3 rooms' do
        let!(:start) { ScheduleItem.beginning_of_day(Time.zone.now.in_website_time_zone + 1.day)}
        let!(:rooms) { 3.times.with_object([]) { |n, rooms| rooms << create(:room, name: "room#{n}") } }

        context '1 schedule items going on at the same time' do
          # +------+      +------+
          # |xx    |  =>  |xxxxxx|
          # |xx    |      |xxxxxx|
          # +------+      +------+

          let!(:schedule_items) do
            [build(:schedule_item, start: start, room: rooms[0])]
          end

          subject { schedule_items_styles(schedule_items) }

          it { expect(subject.width(schedule_items[0])).to be_within(0.1).of(100) }

          it { expect(subject.left(schedule_items[0])).to be_within(0.1).of(0) }

        end

        context '2 schedule items going on at the same time' do
          # +------+      +------+
          # |xx  @@|  =>  |xxx@@@|
          # |xx  @@|      |xxx@@@|
          # +------+      +------+

          let!(:schedule_items) do
            items = []
            items << build(:schedule_item, start: start, duration: 30, room: rooms[0])
            items << build(:schedule_item, start: start, duration: 30, room: rooms[2])
          end

          subject { schedule_items_styles(schedule_items) }

          it { expect(subject.width(schedule_items[0])).to be_within(0.1).of(50) }
          it { expect(subject.width(schedule_items[1])).to be_within(0.1).of(50) }

          it { expect(subject.left(schedule_items[0])).to be_within(0.1).of(0) }
          it { expect(subject.left(schedule_items[1])).to be_within(0.1).of(50) }
        end

        context '3 schedule items going on at the same time' do
          # +------+      +------+
          # |xx^^@@|  =>  |xx^^@@|
          # |xx^^@@|      |xx^^@@|
          # +------+      +------+

          let!(:schedule_items) do
            items = []
            items << build(:schedule_item, start: start, duration: 30, room: rooms[0])
            items << build(:schedule_item, start: start, duration: 30, room: rooms[1])
            items << build(:schedule_item, start: start, duration: 30, room: rooms[2])
          end

          subject { schedule_items_styles(schedule_items) }

          it { expect(subject.width(schedule_items[0])).to be_within(0.1).of(33.33) }
          it { expect(subject.width(schedule_items[1])).to be_within(0.1).of(33.33) }
          it { expect(subject.width(schedule_items[2])).to be_within(0.1).of(33.33) }

          it { expect(subject.left(schedule_items[0])).to be_within(0.1).of(0) }
          it { expect(subject.left(schedule_items[1])).to be_within(0.1).of(33.33) }
          it { expect(subject.left(schedule_items[2])).to be_within(0.1).of(66.66) }
        end

        context '2 schedule items going on at the different times' do
          # +------+      +------+
          # |xx    |  =>  |xxxxxx|
          # |xx    |      |xxxxxx|
          # |    @@|      |@@@@@@|
          # +------+      +------+

          let!(:schedule_items) do
            items = []
            items << build(:schedule_item, start: start, duration: 30,  room: rooms[0])
            items << build(:schedule_item, start: start + 45.minutes, duration: 15, room: rooms[2])
          end

          subject { schedule_items_styles(schedule_items) }

          it { expect(subject.width(schedule_items[0])).to be_within(0.1).of(100) }
          it { expect(subject.width(schedule_items[1])).to be_within(0.1).of(100) }

          it { expect(subject.left(schedule_items[0])).to be_within(0.1).of(0) }
          it { expect(subject.left(schedule_items[1])).to be_within(0.1).of(0) }
        end

        context '2 schedule items overlapping' do
          # +------+      +------+
          # |xx    |  =>  |xxx   |
          # |xx  @@|      |xxx@@@|
          # |    @@|      |   @@@|
          # +------+      +------+

          let!(:schedule_items) do
            items = []
            items << build(:schedule_item, start: start, duration: 30, room: rooms[0])
            items << build(:schedule_item, start: start + 15.minutes, duration: 30, room: rooms[2])
          end

          subject { schedule_items_styles(schedule_items) }

          it { expect(subject.width(schedule_items[0])).to be_within(0.1).of(50) }
          it { expect(subject.width(schedule_items[1])).to be_within(0.1).of(50) }

          it { expect(subject.left(schedule_items[0])).to be_within(0.1).of(0) }
          it { expect(subject.left(schedule_items[1])).to be_within(0.1).of(50) }
        end

        context '3 schedule items at max going on at the same time, 3 long items forming \'stairs\'' do
          # +------+      +------+
          # |xx    |  =>  |xx    |
          # |xx@@  |      |xx@@  |
          # |  @@**|      |  @@**|
          # |^^@@**|      |^^@@**|
          # |^^  **|      |^^  **|
          # |    **|      |    **|
          # +------+      +------+

          let!(:schedule_items) do
            items = []
            items << build(:schedule_item, start: start, duration: 30, room: rooms[0]) # x
            items << build(:schedule_item, start: start + 20.minutes, duration: 60, room: rooms[1]) # @
            items << build(:schedule_item, start: start + 40.minutes, duration: 90, room: rooms[2]) # *
            items << build(:schedule_item, start: start + 60.minutes, duration: 30, room: rooms[0]) # ^
          end

          subject { schedule_items_styles(schedule_items) }

          it { expect(subject.width(schedule_items[0])).to be_within(0.1).of(33.33) }
          it { expect(subject.width(schedule_items[1])).to be_within(0.1).of(33.33) }
          it { expect(subject.width(schedule_items[2])).to be_within(0.1).of(33.33) }
          it { expect(subject.width(schedule_items[3])).to be_within(0.1).of(33.33) }

          it { expect(subject.left(schedule_items[0])).to be_within(0.1).of(0) }
          it { expect(subject.left(schedule_items[1])).to be_within(0.1).of(33.33) }
          it { expect(subject.left(schedule_items[2])).to be_within(0.1).of(66.66) }
          it { expect(subject.left(schedule_items[3])).to be_within(0.1).of(0) }
        end
      end
    end

    describe '#top' do
      let!(:today) { Time.zone.now.in_website_time_zone }

      let(:schedule_item_beginning) { build(
        :schedule_item,
        start: ScheduleItem.beginning_of_day(today)
      )}

      let(:schedule_item_middle) { build(
        :schedule_item,
        start: ScheduleItem.beginning_of_day(today) + (ScheduleItem.day_duration_in_quarters * 15 / 2).minutes
      )}

      let(:schedule_item_end) { build(
        :schedule_item,
        start: ScheduleItem.end_of_day(today) - 1.hour
      )}

      let(:styles) { schedule_items_styles([schedule_item_beginning, schedule_item_middle, schedule_item_end]) }

      context 'starts at the beginning of the day' do
        subject { styles.top(schedule_item_beginning) }
        it { is_expected.to be_within(1).of(0) }
      end

      context 'starts in the middle of the day' do
        subject { styles.top(schedule_item_middle) }
        it { is_expected.to be_within(1).of(50) }
      end

      context 'starts at the end of the day' do
        subject { styles.top(schedule_item_end) }
        it { is_expected.to be_within(1).of(100 - (100 * 4 / ScheduleItem.day_duration_in_quarters)) }
      end
    end

    describe '#height' do
      let!(:today) { Time.zone.now.in_website_time_zone }

      let(:one_hour_schedule_item) { build(
        :schedule_item,
        start: ScheduleItem.beginning_of_day(today),
        duration: 60
      )}

      let(:twenty_three_hour_schedule_item) { build(
        :schedule_item,
        start: ScheduleItem.beginning_of_day(today),
        duration: ScheduleItem.day_duration_in_quarters * 15
      )}

      let(:styles) { schedule_items_styles([one_hour_schedule_item, twenty_three_hour_schedule_item]) }

      context 'is 1 hour long' do
        subject { styles.height(one_hour_schedule_item) }
        it { is_expected.to be_within(1).of((100 * 4 / ScheduleItem.day_duration_in_quarters)) }
      end

      context 'is all day long' do
        subject { styles.height(twenty_three_hour_schedule_item) }
        it { is_expected.to be_within(1).of(100) }
      end
    end
  end
end