require 'rails_helper'

RSpec.describe Admin::RoomsController do
  shared_examples 'access denied' do
    describe 'GET #index' do
      subject(:request) { get :index }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'GET #new' do
      subject(:request) { get :new }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'POST #create' do
      subject(:request) { post :create, room: build(:room) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'PUT #update' do
      subject(:request) { put :update, id: create(:room), room: attributes_for(:room) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'DELETE #destroy' do
      subject(:request) { delete :destroy, id: create(:room) }

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

    describe 'GET #index' do
      let!(:rooms) { create_list :room, 3 }
      subject { get :index }

      it { is_expected.to render_template :index }
      it { is_expected.to expose :rooms, rooms }
    end

    describe 'GET #new' do
      subject { get :new }

      it { is_expected.to render_template :new }
    end

    describe 'GET #edit' do
      let!(:room) { create :room }
      subject { get :edit, id: room.id }

      it { is_expected.to render_template :edit }
      it { is_expected.to expose :room, room }
    end

    describe 'PUT #update' do
      let!(:room) { create :room, name: 'Small room' }

      context 'with valid attributes' do
        before :each do
          put :update, id: room.id, room: { name: 'Big room' }
        end

        it { expect(room.reload.name).to eq 'Big room' }

        it 'redirects to index with a notice' do
          is_expected.to redirect_to action: :index, anchor: Room.last.decorate.css_id
          expect(controller).to set_flash[:notice].to 'Location has been updated!'
        end
      end

      context 'with invalid attributes' do
        before :each do
          put :update, id: room.id, room: { name: '' }
        end

        it { expect(room.reload.name).to eq 'Small room' }
        it { is_expected.to render_template :edit }
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        subject { post :create, room: attributes_for(:room) }

        it { expect { subject }.to change(Room, :count).by(1) }

        it 'redirects to index with a notice' do
          is_expected.to redirect_to action: :index, anchor: Room.last.decorate.css_id
          expect(controller).to set_flash[:notice].to 'Location has been created!'
        end
      end

      context 'with invalid attributes' do
        subject { post :create, room: { name: '', description: ''} }

        it { expect { subject }.not_to change(Room, :count) }
        it { is_expected.to render_template :new }
      end
    end

    describe 'DELETE #destroy' do
      let!(:room) { create :room }
      subject { xhr :delete, :destroy, id: room.id }

      it { expect { subject }.to change(Room, :count).by(-1) }
      it { is_expected.to render_template :destroy }

      it 'sets notice' do
        subject
        expect(controller).to set_flash.now[:notice].to 'Location has been deleted!'
      end
    end
  end
end