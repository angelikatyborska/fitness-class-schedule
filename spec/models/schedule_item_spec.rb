require 'rails_helper'

RSpec.describe ScheduleItem do
  describe 'validations' do
    it { is_expected.to validate_presence_of :start }
    it { is_expected.to validate_presence_of :duration }
    it { is_expected.to validate_presence_of :capacity }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_inclusion_of(:type).in_array(ScheduleItem.types) }

    it 'fail when starts in the past' do
      schedule_item = ScheduleItem.new(
        start: DateTime.now - 1.day,
        duration: 45,
        type: ScheduleItem.types[0]
      )
      expect(schedule_item.valid?).to be false
      expect(schedule_item.errors[:start]).to include('can\'t be in the past')
    end

    it 'fail when doesn\'t end on the same day' do
      schedule_item = ScheduleItem.new(
        start: DateTime.now.beginning_of_day + 1.day,
        duration: 25 * 60,
        type: ScheduleItem.types[0]
      )
      expect(schedule_item.valid?).to be false
      expect(schedule_item.errors[:duration]).to include('must end on the same day')
    end
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :start }
    it { is_expected.to have_db_index :start }
    it { is_expected.to have_db_column :duration }
    it { is_expected.to have_db_index :duration }
    it { is_expected.to have_db_column :type }
    it { is_expected.to have_db_column :capacity }
  end

  describe 'associations' do
    it { is_expected.to have_one :trainer }
    it { is_expected.to have_one :room}
    it { is_expected.to have_many :reservations }
  end
end