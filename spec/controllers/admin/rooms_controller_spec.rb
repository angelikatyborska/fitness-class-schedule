require 'rails_helper'

RSpec.describe Admin::RoomsController do
  shared_examples 'access denied' do
    describe 'GET #index' do
      it 'raises an error' do
        expect { get :index }.to require_admin_privileges
      end
    end

    describe 'GET #new' do
      it 'raises an error' do
        expect { get :new }.to require_admin_privileges
      end
    end

    describe 'POST #create' do
      it 'raises an error' do
        expect { post :create, room: build(:room) }.to require_admin_privileges
      end
    end

    describe 'PUT #update' do
      it 'raises an error' do
        expect { put :update, id: create(:room), room: attributes_for(:room) }.to require_admin_privileges
      end
    end

    describe 'DELETE #destroy' do
      it 'raises an error' do
        expect { delete :destroy, id: create(:room) }.to require_admin_privileges
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

    describe 'GET #index' do
      let!(:rooms) { create_list(:room, 3) }
      subject { get :index }

      it { is_expected.to render_template :index }
      it 'exposes schedule items' do
        expect(controller.rooms).to match_array rooms
      end
    end

    describe 'GET #edit' do
      let!(:room) { create(:room) }
      subject { get :edit, id: room.id }

      it { is_expected.to render_template :edit }
    end

    describe 'PUT #update' do
      let!(:room) { create(:room, name: 'Small room') }

      before :each do
        put :update, id: room.id, room: { name: 'Big room' }
      end

      it 'updates room attributes' do
        expect(room.reload.name).to eq 'Big room'
      end
    end

    describe 'POST #create' do
      subject { post :create, room: attributes_for(:room) }

      it {
        expect { subject }.to change(Room, :count).by(1)
      }
    end

    describe 'DELETE #destroy' do
      let!(:room) { create(:room) }
      subject { delete :destroy, id: room.id }

      it { expect { subject }.to change(Room, :count).by(-1) }
    end
  end
end