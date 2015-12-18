require 'rails_helper'

RSpec.describe ScheduleItem do
  describe 'validations' do
    it { is_expected.to validate_presence_of :start }
    it { is_expected.to validate_presence_of :duration }
    it { is_expected.to validate_presence_of :capacity }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_inclusion_of(:type).in_array(ScheduleItem.types) }

    context 'with start date in the past' do
      subject { build(:schedule_item, start: DateTime.now - 1.day) }

      it { is_expected.not_to be_valid }

      it 'has proper error messages' do
        expect(subject.errors[:start]).to include('can\'t be in the past')
      end
    end

    context 'with duration overlapping to the next day' do
      subject { build(:schedule_item, start: DateTime.now.beginning_of_day + 1.day, duration: 25 * 60) }

      it { is_expected.not_to be_valid }

      it 'has proper error messages' do
        expect(subject.errors[:duration]).to include('must end on the same day')
      end
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