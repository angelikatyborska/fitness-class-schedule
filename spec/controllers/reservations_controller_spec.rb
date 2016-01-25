require 'rails_helper'

RSpec.describe ReservationsController do
  let!(:schedule_item) { create :schedule_item }
  let!(:user) { create :user }

  shared_examples 'access denied' do
    describe 'GET #index' do
      subject { get :index, user_id: user.id }

      it 'requires login' do
        expect(subject).to require_login
      end
    end

    describe 'POST #create' do
      subject { xhr :post, :create, user_id: user.id, reservation: { schedule_item_id: schedule_item.id } }

      it { is_expected.to require_login }
    end
  end

  describe 'guest access' do
    it_behaves_like 'access denied'
  end

  describe 'user access' do
    let!(:other_user) { create :user }

    before { sign_in other_user }

    context 'for other user' do
      it_behaves_like 'access denied'
    end

    context 'for the same user' do
      describe 'GET #index' do
        let!(:schedule_item) { create :schedule_item, capacity: 1 }
        let!(:someone_elses_reservation) { create :reservation, schedule_item: schedule_item }
        let!(:queued_reservation) { create :reservation, user: other_user, schedule_item: schedule_item }
        let!(:active_reservation) { create :reservation, user: other_user, status: 'active' }
        let!(:attended_reservation) { create :reservation, user: other_user, status: 'attended' }
        let!(:missed_reservation) { create :reservation, user: other_user, status: 'missed' }

        subject { get :index, user_id: other_user.id }

        it 'renders template index' do
          is_expected.to render_template :index
        end

        it 'exposes current user\'s reservations' do
          subject
          expect(controller.reservations).to match_array [queued_reservation, active_reservation, attended_reservation, missed_reservation]
          expect(controller.not_queued_reservations).to eq [active_reservation]

          expect(controller.queued_reservations).to match_array [queued_reservation]
          expect(controller.attended_reservations).to match_array [attended_reservation]
          expect(controller.missed_reservations).to match_array [missed_reservation]
        end
      end

      describe 'DELETE #destroy' do
        let!(:reservation) { create :reservation, user: other_user }
        subject { xhr :delete, :destroy, user_id: other_user.id, id: reservation.id }

        context 'within time allowed for cancellations' do
          it 'deletes the reservation' do
            Timecop.freeze(reservation.schedule_item.start - Configurable.cancellation_deadline.hours - 1.hour)

            expect{ subject }.to change(other_user.reservations, :count).by(-1)

            Timecop.return
          end
        end

        context 'after time allowed for cancellations has passed' do
          it 'does not delete the reservation' do
            Timecop.freeze(reservation.schedule_item.start - Configurable.cancellation_deadline.hours + 15.minutes)

            expect{ subject }.not_to change(other_user.reservations, :count)

            Timecop.return
          end
        end
      end

      describe 'POST #create' do
        context 'with valid attributes' do
          it 'creates a reservation' do
            expect {
              xhr :post, :create, user_id: other_user.id, reservation: { schedule_item_id: schedule_item.id }
            }.to change(Reservation, :count).by(1)
          end
        end

        context 'with invalid attributes' do
          let!(:other_reservation) { create :reservation, user: other_user }

          it 'doesn\'t create a reservation' do
            expect {
              xhr :post, :create, user_id: other_user.id, reservation: { schedule_item_id: other_reservation.schedule_item.id }
            }.not_to change(Reservation, :count)
          end
        end
      end
    end
  end
end