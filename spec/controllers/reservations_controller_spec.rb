require 'rails_helper'

RSpec.describe ReservationsController do
  let!(:schedule_item) { create :schedule_item }
  let!(:user) { create :user }

  shared_examples 'access denied' do
    describe 'GET #index' do
      subject { get :index, user_id: user.id }

      it { is_expected.to require_login }
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

        it { is_expected.to render_template :index }

        it 'exposes current user\'s reservations by status' do
         is_expected.to expose :reservations, [queued_reservation, active_reservation, attended_reservation, missed_reservation]
         is_expected.to expose :not_queued_reservations, [active_reservation]
         is_expected.to expose :queued_reservations, [queued_reservation]
         is_expected.to expose :attended_reservations, [attended_reservation]
         is_expected.to expose :missed_reservations, [missed_reservation]
        end
      end

      describe 'DELETE #destroy' do
        let!(:reservation) { create :reservation, user: other_user }
        subject { xhr :delete, :destroy, user_id: other_user.id, id: reservation.id }

        context 'within time allowed for cancellations' do
          before :each do
            Timecop.freeze(reservation.schedule_item.start - SiteSettings.instance.cancellation_deadline.hours - 1.hour)
          end

          after :each do
            Timecop.return
          end

          it { expect { subject }.to change(other_user.reservations, :count).by(-1) }
          it { is_expected.to render_template :destroy }

          it 'sets a notice' do
            subject
            expect(controller).to set_flash.now[:notice].to 'Your reservation has been deleted.'
          end
        end

        context 'after time allowed for cancellations has passed' do
          before :each do
            Timecop.freeze(reservation.schedule_item.start - SiteSettings.instance.cancellation_deadline.hours + 15.minutes)
          end

          after :each do
            Timecop.return
          end

          it { expect { subject }.not_to change(other_user.reservations, :count) }
          it { is_expected.to render_template 'reservations/alert.js' }
        end
      end

      describe 'POST #create' do
        context 'with valid attributes' do
          subject { xhr(
            :post,
            :create,
            user_id: other_user.id,
            reservation: { schedule_item_id: schedule_item.id }
          )}

          it { expect { subject }.to change(Reservation, :count).by(1) }
        end

        context 'with invalid attributes' do
          let!(:other_reservation) { create :reservation, user: other_user }

          subject { xhr(
            :post,
            :create,
            user_id: other_user.id,
            reservation: { schedule_item_id: other_reservation.schedule_item.id }
          )}

          it { expect { subject }.not_to change(Reservation, :count) }
        end
      end
    end
  end
end
