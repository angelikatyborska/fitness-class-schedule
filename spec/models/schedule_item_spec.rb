require 'rails_helper'

RSpec.describe ScheduleItem do
  include ApplicationHelper

  describe 'validations' do
    it { is_expected.to validate_presence_of :trainer }
    it { is_expected.to validate_presence_of :room }
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

    context 'with duration exceeding day end by 15 minutes' do
      subject { build(:schedule_item, start: (ScheduleItem.end_of_day(Time.zone.now + 1.day) - 30.minutes) , duration: 45) }

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:start]).to include('can\'t be that late')
      end
    end

    context 'with start date earlier than day start' do
      subject { build(:schedule_item, start: ScheduleItem.beginning_of_day(Time.zone.now) - 1.hour + 1.day)}

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:start]).to include('can\'t be that early')
      end
    end

    context 'with start date later than day end' do
      subject { build(:schedule_item, start: ScheduleItem.end_of_day(Time.zone.now) + 1.hour + 1.day)}

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:start]).to include('can\'t be that late')
      end
    end

    context 'with a room that is already occupied' do
      let!(:room) { create(:room) }
      let!(:schedule_item_occupying_the_room) { create(:schedule_item, room: room, start: ScheduleItem.beginning_of_day(Time.zone.now + 1.day), duration: 60) }

      subject { build(:schedule_item, room: room, start: ScheduleItem.beginning_of_day(Time.zone.now + 1.day) + 15.minutes)}

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:room]).to include('is already occupied at this time')
      end
    end

    context 'with a trainer that is already occupied' do
      let!(:trainer) { create(:trainer) }
      let!(:schedule_item_occupying_the_room) { create(:schedule_item, trainer: trainer, start: ScheduleItem.beginning_of_day(Time.zone.now + 1.day), duration: 60) }

      subject { build(:schedule_item, trainer: trainer, start: ScheduleItem.beginning_of_day(Time.zone.now + 1.day) + 15.minutes)}

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:trainer]).to include('is already occupied at this time')
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

  describe 'scopes' do
    describe 'week' do
      before :all do
        @today = Time.zone.now
        @this_week_items = 2.times.with_object([]) do |n, items|
          items << build(:schedule_item_this_week)
        end

        @next_week_items = 2.times.with_object([]) do |n, items|
          items << build(:schedule_item_next_week)
        end

        (@this_week_items + @next_week_items).each do |item|
          item.save(validate: false)
        end
      end

      context 'without argument' do
        subject { described_class.week }

        it 'lists all schedule items starting this week' do
          is_expected.to include *(@this_week_items)
          is_expected.not_to include *(@next_week_items)
        end
      end

      context 'with next week\'s date' do
        subject { described_class.week(@today + 7.days) }

        it 'lists all schedule items starting next week' do
          is_expected.not_to include *(@this_week_items)
          is_expected.to include *(@next_week_items)
        end
      end
    end
  end

  describe '#going_on_at?' do
    let(:now) { Time.zone.now }

    context 'with a schedule item that starts just now' do
      subject { build(:schedule_item, start: now, duration: 60) }

      it 'returns true' do
        subject.save(validate: false)
        expect(subject.going_on_at?(now)).to eq true
      end
    end

    context 'with a schedule item that started 5 minutes before' do
      subject { build(:schedule_item, start: now - 5.minutes, duration: 60) }

      it 'returns true' do
        subject.save(validate: false)
        expect(subject.going_on_at?(now)).to eq true
      end
    end

    context 'with a schedule item that is not currently going on' do
      subject { create(:schedule_item, start: ScheduleItem.beginning_of_day(now + 1.day), duration: 60) }

      it 'returns true' do
        expect(subject.going_on_at?(now)).to eq false
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