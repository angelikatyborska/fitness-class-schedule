require 'rails_helper'

RSpec.describe ScheduleItem do
  describe 'validations' do
    it { is_expected.to validate_presence_of :start }
    it { is_expected.to validate_presence_of :duration }
    it { is_expected.to validate_numericality_of(:duration).is_greater_than(0) }
    it { is_expected.to validate_presence_of :capacity }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }
    it { is_expected.to validate_presence_of :activity }
    it { is_expected.to validate_inclusion_of(:activity).in_array(ScheduleItem.activities) }

    context 'with start date in the past' do
      subject { build(:schedule_item, start: Time.zone.now - 1.day) }

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:start]).to include('can\'t be in the past')
      end
    end

    context 'with duration overlapping to the next day' do
      subject { build(:schedule_item, start: Time.zone.now.beginning_of_day + 1.day, duration: 25 * 60) }

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:duration]).to include('must start and end on the same day')
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
end