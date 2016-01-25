require 'rails_helper'

RSpec.describe Admin::RoomPhotosController do
  let!(:room) { create :room }

  shared_examples 'access denied' do
    describe 'GET #new' do
      it 'raises an error' do
        expect { xhr :get, :new, room_id: room.id }.to require_admin_privileges
      end
    end

    describe 'POST #create' do
      it 'raises an error' do
        expect { post :create, room_id: room.id, room_photo: build(:room_photo) }.to require_admin_privileges
      end
    end

   describe 'DELETE #destroy' do
      it 'raises an error' do
        expect { delete :destroy, room_id: room.id, id: create(:room_photo) }.to require_admin_privileges
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
      subject { xhr :get, :new, room_id: room.id }

      it 'renders template new' do
        is_expected.to render_template :new
      end
    end

    describe 'POST #create' do
      subject { post :create, room_id: room.id, room_photo: attributes_for(:room_photo) }

      it 'creates a room photo' do
        expect { subject }.to change(RoomPhoto, :count).by(1)
      end
    end

    describe 'DELETE #destroy' do
      let!(:room_photo) { create :room_photo }
      subject { delete :destroy, room_id: room_photo.room.id, id: room_photo.id }

      it 'deletes the room photo' do
        expect { subject }.to change(RoomPhoto, :count).by(-1)
      end
    end
  end
end