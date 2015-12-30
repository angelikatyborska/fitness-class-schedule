require 'rails_helper'

RSpec.describe Reservation do
  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :schedule_item }
    it { is_expected.to validate_presence_of :status }

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
      let!(:schedule_item) { create(:schedule_item) }
      let!(:user) { create(:user) }
      let!(:other_reservation) { create(:reservation, schedule_item: schedule_item, user: user) }

      subject { build(:reservation, schedule_item: schedule_item, user: user) }

      it 'is invalid' do
        is_expected.to be_invalid
        expect(subject.errors[:user]).to include('has already been taken')
      end
    end
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :queue_position }
    it { is_expected.to have_db_index :queue_position }

  end

  describe '#queue_position' do
    context 'with all reservations for the same schedule item' do
      let(:schedule_item) { create(:schedule_item) }

      let!(:reservations) { create_list(:reservation, 4, schedule_item: schedule_item) }

      it 'queues reservations in the same order they were created' do
        expect(reservations[0].queue_position).to eq 1
        expect(reservations[1].queue_position).to eq 2
        expect(reservations[2].queue_position).to eq 3
        expect(reservations[3].queue_position).to eq 4
      end

      it 'moves reservations in the queue by one position when a reservation is removed' do
        reservations[1].destroy
        expect(reservations[0].reload.queue_position).to eq 1
        expect(reservations[2].reload.queue_position).to eq 2
        expect(reservations[3].reload.queue_position).to eq 3
      end
    end

    context 'with reservations for different schedule items' do
      let!(:reservations) { create_list(:reservation, 4) }

      it 'queues each reservation seperately' do
        expect(reservations[0].queue_position).to eq 1
        expect(reservations[1].queue_position).to eq 1
        expect(reservations[2].queue_position).to eq 1
        expect(reservations[3].queue_position).to eq 1
      end


      it 'does not move reservations in their respective queues' do
        reservations[1].destroy
        expect(reservations[0].reload.queue_position).to eq 1
        expect(reservations[2].reload.queue_position).to eq 1
        expect(reservations[3].reload.queue_position).to eq 1
      end
    end
  end
end
