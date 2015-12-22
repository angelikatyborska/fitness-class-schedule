require 'rails_helper'

RSpec.describe ScheduleItem do
  include ApplicationHelper

  describe 'validations' do
    it { is_expected.to validate_presence_of :start }
    it { is_expected.to validate_presence_of :duration }
    it { is_expected.to validate_numericality_of(:duration).is_greater_than(0) }
    it { is_expected.to validate_presence_of :capacity }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }
    it { is_expected.to validate_presence_of :activity }
    it { is_expected.to validate_inclusion_of(:activity).in_array(ScheduleItem.activities) }

    context 'with start date in the past' do
      subject { build(:schedule_item, start: ScheduleItem.beginning_of_day(Time.zone.now - 1.day)) }

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:start]).to include('can\'t be in the past')
      end
    end

    context 'with duration overlapping to the next day' do
      subject { build(:schedule_item, duration: 25 * 60) }

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:duration]).to include('can\'t span more than one day')
      end
    end

    context 'with start date earlier than day start' do
      subject { build(:schedule_item, start: ScheduleItem.beginning_of_day(Time.zone.now) - 1.hour + 1.day)}

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:start]).to include('can\'t start that early')
      end
    end
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :start }
    it { is_expected.to have_db_column :duration }
    it { is_expected.to have_db_column :activity }
    it { is_expected.to have_db_column :capacity }
    it { is_expected.to have_db_index :start }
    it { is_expected.to have_db_index :duration }
  end

  describe 'associations' do
    it { is_expected.to belong_to :trainer }
    it { is_expected.to belong_to :room}
    it { is_expected.to have_many :reservations }
  end

  describe 'scope' do
    describe 'week' do
      before :all do
        @today = Time.zone.now
        @this_week_item_1 = build(:schedule_item_this_week)
        @this_week_item_1.save(validate: false)
        @this_week_item_2 = build(:schedule_item_this_week)
        @this_week_item_2.save(validate: false)
        @next_week_item_1 = build(:schedule_item_next_week)
        @next_week_item_1.save(validate: false)
        @next_week_item_2 = build(:schedule_item_next_week)
        @next_week_item_2.save(validate: false)

        [@this_week_item_1, @this_week_item_2, @next_week_item_1, @next_week_item_2].each do |item|
          item.save(validate: false)
        end
      end

      context 'without argument' do
        subject { described_class.week }

        it 'lists all schedule items starting this week' do
          is_expected.to include @this_week_item_1, @this_week_item_2
          is_expected.not_to include @next_week_item_1, @next_week_item_2
        end
      end

      context 'with next week\'s date' do
        subject { described_class.week(@today + 7.days) }

        it 'lists all schedule items starting next week' do
          is_expected.not_to include @this_week_item_1, @this_week_item_2
          is_expected.to include @next_week_item_1, @next_week_item_2
        end
      end
    end
  end

  describe 'class methods' do
    describe '#beginning_of_day' do
      let(:today) { Time.zone.now }
      subject { described_class.beginning_of_day(today) }

      it 'returns the earliest time a schedule item can start this day' do
        expect(subject.hour).to eq Configurable.day_start
        expect(subject.min).to eq 0
      end
    end
    describe '#end_of_day' do
      let(:today) { Time.zone.now }
      subject { described_class.end_of_day(today) }

      it 'returns the earliest time that is too late for a schedule item to start this day' do
        expect(subject.hour).to eq Configurable.day_end
        expect(subject.min).to eq 0
      end
    end
  end
end