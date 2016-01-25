require 'rails_helper'

RSpec.describe Admin::ReservationsController do
  shared_examples 'access denied' do
    describe 'GET #new' do
      it 'raises an error' do
        expect { get :new }.to require_admin_privileges
      end
    end

    describe 'POST #create' do
      it 'raises an error' do
        expect { xhr :post, :create, reservation: build(:reservation) }.to require_admin_privileges
      end
    end

    describe 'PUT #update' do
      it 'raises an error' do
        expect { xhr :put, :update, id: create(:reservation), reservation: attributes_for(:reservation) }.to require_admin_privileges
      end
    end

    describe 'DELETE #destroy' do
      it 'raises an error' do
        expect { xhr :delete, :destroy, id: create(:reservation) }.to require_admin_privileges
      end
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

      it 'renders template new' do
        is_expected.to render_template :new
      end

      it 'exposes a reservation for the given schedule item' do
        subject
        expect(controller.reservation.schedule_item).to eq schedule_item
      end
    end

    describe 'PUT #update' do
      let!(:user) { create :user }
      let!(:schedule_item) { create :schedule_item }
      let!(:reservation) { create :reservation, schedule_item_id: schedule_item.id, user_id: user.id, status: 'missed' }

      before :each do
        xhr :put, :update, id: reservation.id, reservation: { schedule_item_id: schedule_item.id, user_id: user.id, status: 'active' }
      end

      it 'updates fitness class attributes' do
        subject
        expect(reservation.reload.status).to eq 'active'
      end
    end

    describe 'POST #create' do
      let!(:user) { create :user }
      let!(:schedule_item) { create :schedule_item }
      subject { xhr :post, :create, reservation: { schedule_item_id: schedule_item.id, user_id: user.id } }

      it 'creates a reservation' do
        expect { subject }.to change(Reservation, :count).by(1)
      end
    end

    describe 'DELETE #destroy' do
      let!(:reservation) { create :reservation }
      subject { xhr :delete, :destroy, id: reservation.id }

      it 'deletes the reservation' do
        expect { subject }.to change(Reservation, :count).by(-1)
      end
    end
  end
end