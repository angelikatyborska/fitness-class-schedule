require 'rails_helper'

RSpec.describe Admin::ReservationsController do
  shared_examples 'access denied' do
    describe 'GET #new' do
      subject(:request) { get :new }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'POST #create' do
      subject(:request) { xhr :post, :create, reservation: build(:reservation) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'PUT #update' do
      subject(:request) { xhr :put, :update, id: create(:reservation), reservation: attributes_for(:reservation) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'DELETE #destroy' do
      subject(:request) { xhr :delete, :destroy, id: create(:reservation) }

      it { expect { request }.to require_admin_privileges }
    end
  end

  describe 'guest access' do
    it_behaves_like 'access denied'
  end

  describe 'user access' do
    let(:user) { create :user }

    before { sign_in user }

    it_behaves_like 'access denied'
  end

  describe 'admin access' do
    let(:admin) { create :admin_user }

    before { sign_in admin }

    describe 'GET #new' do
      let!(:schedule_item) { create :schedule_item }
      subject { xhr :get, :new, schedule_item: schedule_item }

      it { is_expected.to render_template :new }
    end

    describe 'PUT #update' do
      let!(:user) { create :user }
      let!(:schedule_item) { create :schedule_item }
      let!(:reservation) { create :reservation, schedule_item_id: schedule_item.id, user_id: user.id, status: 'missed' }

      context 'with valid attributes' do
        before :each do
          xhr :put, :update, id: reservation.id, reservation: {
            schedule_item_id: schedule_item.id,
            user_id: user.id,
            status: 'active'
          }
        end

        it { expect(reservation.reload.status).to eq 'active' }
      end

      context 'with invalid attributes' do
        before :each do
          xhr :put, :update, id: reservation.id, reservation: { schedule_item_id: '' }
        end

        it { expect(reservation.reload.schedule_item).to eq schedule_item }
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        let!(:user) { create :user }
        let!(:schedule_item) { create :schedule_item }
        subject { xhr :post, :create, reservation: { schedule_item_id: schedule_item.id, user_id: user.id } }

        it { expect { subject }.to change(Reservation, :count).by(1) }
      end
    end

    describe 'DELETE #destroy' do
      let!(:reservation) { create :reservation }
      subject { xhr :delete, :destroy, id: reservation.id }

      it { expect { subject }.to change(Reservation, :count).by(-1) }
      it { is_expected.to render_template :destroy }

      it 'sets notice' do
        subject
        expect(controller).to set_flash.now[:notice].to 'Reservation has been deleted!'
      end
    end
  end
end