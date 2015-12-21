require 'rails_helper'

RSpec.describe Reservation do
  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :schedule_item }

    context 'with schedule item starting in the past' do
      subject { build(:reservation, schedule_item: build(:schedule_item, start: Time.zone.now - 1.day ))}

      it 'is invalid' do
        is_expected.to be_invalid
        expect(subject.errors[:schedule_item]).to include('can\'t make reservations for items from the past')
      end
    end

    context 'with schedule_items that can\'t accept any more users' do
      before :all do
        @full_schedule_item = create(:schedule_item, capacity: 1)
        create(:reservation, schedule_item: @full_schedule_item)
      end

      subject { build(:reservation, schedule_item: @full_schedule_item) }

      it 'is invalid' do
        is_expected.to be_invalid
        expect(subject.errors[:schedule_item]).to include('schedule_item capacity exceeded')
      end
    end

    # this could be tested using shoulda-matcher validate_uniqueness_of().scoped_to(), but it doesn't work for some reason
    context 'with user having already made a reservation for this schedule item' do
      before :all do
        @schedule_item = create(:schedule_item)
        @user = create(:user)
        create(:reservation, schedule_item: @schedule_item, user: @user)
      end

      subject { build(:reservation, schedule_item: @schedule_item, user: @user) }

      it 'is invalid' do
        is_expected.to be_invalid
        expect(subject.errors[:user]).to include('has already been taken')
      end
    end
  end
end
