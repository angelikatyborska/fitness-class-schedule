require 'rails_helper'

RSpec.describe Reservation do
  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :schedule_item }

    context 'with schedule item starting in the past' do
      subject { build :reservation, schedule_item: build(:schedule_item, start: Time.zone.now - 1.day) }

      it 'is invalid' do
        is_expected.to be_invalid
        expect(subject.errors[:schedule_item]).to include('can\'t make reservations for items from the past')
      end
    end

    context 'with user having already made a reservation for this schedule item' do
      let!(:schedule_item) { create :schedule_item }
      let!(:user) { create :user }
      let!(:other_reservation) { create :reservation, schedule_item: schedule_item, user: user }

      subject { build :reservation, schedule_item: schedule_item, user: user }

      it 'is invalid' do
        is_expected.to be_invalid
        expect(subject.errors[:user]).to include('has already been taken')
      end
    end

    context 'when trying to change something after create' do
      let!(:reservation) { create :reservation }

      subject { reservation }

      context 'changing user' do
        it 'is invalid' do
          reservation.user = create :user
          is_expected.to be_invalid
          expect(subject.errors[:user_id]).to include('only reservation\'s status can be changed')
        end
      end

      context 'changing schedule item' do
        it 'is invalid' do
          reservation.schedule_item = create :schedule_item
          is_expected.to be_invalid
          expect(subject.errors[:schedule_item_id]).to include('only reservation\'s status can be changed')
        end
      end

      context 'changing status' do
        it 'is valid' do
          reservation.status = 'missed'
          is_expected.to be_valid
        end
      end
    end
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :status }
  end

  describe 'destroy' do
    let!(:two_spot_schedule_item) { create :schedule_item, capacity: 2 }

    subject { reservation.destroy }

    context 'active reservation' do
      let!(:reservation) { create :reservation, schedule_item: two_spot_schedule_item }

      context 'other reservations on the waiting list' do
        let!(:other_reservation) { create :reservation, schedule_item: two_spot_schedule_item }
        let!(:waiting_reservations) { create_list :reservation, 3, schedule_item: two_spot_schedule_item }

        it 'sends an email to the first reservation on the waiting list' do
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(ActionMailer::Base.deliveries.last.to).to eq [waiting_reservations[0].user.email]
        end
      end

      context 'no reservations on the waiting list' do
        it 'does not send en email' do
          expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
        end
      end
    end

    context 'queued reservation' do
      let!(:active_reservations) { create_list :reservation, 2, schedule_item: two_spot_schedule_item }
      let!(:reservation) { create :reservation, schedule_item: two_spot_schedule_item }

      it 'does not send en email' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end

  describe '#queue_position' do
    context 'with all reservations for the same schedule item created at the same time' do
      let!(:schedule_item) { create :schedule_item  }

      let!(:reservations) do
        reservations = 4.times.with_object([]) do |n, reservations|
          reservations << { user: create(:user), schedule_item: schedule_item }
        end

        Reservation.create!(reservations)
      end

      it 'queues reservations in the same order they were created' do
        expect(reservations[0].reload.queue_position).to eq 1
        expect(reservations[1].reload.queue_position).to eq 2
        expect(reservations[2].reload.queue_position).to eq 3
        expect(reservations[3].reload.queue_position).to eq 4
      end

      it 'moves reservations in the queue by one position when a reservation is removed' do
        reservations[1].destroy
        expect(reservations[0].reload.queue_position).to eq 1
        expect(reservations[2].reload.queue_position).to eq 2
        expect(reservations[3].reload.queue_position).to eq 3
      end
    end

    context 'with reservations for different schedule items created at the same time' do
      let!(:reservations) do
        reservations = 4.times.with_object([]) do |n, reservations|
          reservations << { user: create(:user), schedule_item: create(:schedule_item) }
        end

        Reservation.create!(reservations)
      end

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

  describe '#queued?' do
    let!(:schedule_item_with_one_spot) { create :schedule_item, capacity: 1 }

    context 'created for a schedule item with empty spots' do
      let!(:reservation) { create :reservation, schedule_item: schedule_item_with_one_spot }

      subject { reservation.queued? }
      it { is_expected.to eq false }
    end

    context 'created at the same time for a schedule item with no empty spots' do
      let!(:reservations) do
        reservations = 3.times.with_object([]) do |n, reservations|
          reservations << { user: create(:user), schedule_item: schedule_item_with_one_spot }
        end

        Reservation.create!(reservations)
      end

      it 'queues reservations that overflow capacity' do
        expect(reservations[0].queued?).to eq false
        expect(reservations[1].queued?).to eq true
        expect(reservations[2].queued?).to eq true
      end

      context 'a spot becomes available' do
        before :each do
          reservations[0].destroy
        end

        it 'makes the first reservation in line active' do
          expect(reservations[1].queued?).to eq false
          expect(reservations[2].queued?).to eq true
        end
      end
    end
  end
end
