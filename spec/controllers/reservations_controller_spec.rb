require 'rails_helper'

RSpec.describe ReservationsController do
  let!(:schedule_item) { create(:schedule_item) }
  let!(:user) { create(:user) }

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
        subject { get :index, user_id: other_user.id }

        it { is_expected.to render_template :index }

        it 'exposes current user\'s reservations' do
          expect(controller.reservations).to eq other_user.reservations
        end
      end

      describe 'DELETE #destroy' do
        let!(:reservation) { create(:reservation, user: other_user) }
        subject { xhr :delete, :destroy, user_id: other_user.id, id: reservation.id }

        it { expect{ subject }.to change(other_user.reservations, :count).by(-1) }
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
          let!(:other_reservation) { create(:reservation, user: other_user) }

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