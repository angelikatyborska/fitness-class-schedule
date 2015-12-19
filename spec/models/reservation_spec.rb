require 'rails_helper'

RSpec.describe Reservation do
  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :schedule_item }

    context 'with schedule item starting in the past' do
      subject { build(:reservation, schedule_item: build(:schedule_item, start: DateTime.now - 1.day ))}
      it 'is invalid' do
        is_expected.to be_invalid
        expect(subject.errors[:schedule_item]).to include('can\'t make reservations for items from the past')
      end
    end
  end
end
