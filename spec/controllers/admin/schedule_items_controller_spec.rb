require 'rails_helper'

RSpec.describe Admin::ScheduleItemsController do
  shared_examples 'access denied' do
    describe 'GET #index' do
      subject(:request) { get :index }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'GET #new' do
      subject(:request) { get :new }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'GET #show' do
      subject(:request) { get :show, id: create(:schedule_item) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'POST #create' do
      subject(:request) { post :create, schedule_item: build(:schedule_item) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'PUT #update' do
      subject(:request) { put :update, id: create(:schedule_item), schedule_item: attributes_for(:schedule_item) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'DELETE #destroy' do
      subject(:request) { delete :destroy, id: create(:schedule_item) }

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
      let!(:schedule_items) { create_list :schedule_item, 3 }
      subject { get :index }

      it { is_expected.to render_template :index }
      it { is_expected.to expose :schedule_items, schedule_items }
    end

    describe 'GET #show' do
      let!(:schedule_item) { create :schedule_item }
      subject { get :show, id: schedule_item.id }

      it { is_expected.to render_template :show }
      it { is_expected.to expose :schedule_item, schedule_item }
    end

    describe 'GET #new' do
      subject { get :new }

      it { is_expected.to render_template :new }
    end

    describe 'GET #edit' do
      let!(:schedule_item) { create :schedule_item }
      subject { get :edit, id: schedule_item.id }

      it { is_expected.to render_template :edit }
      it { is_expected.to expose :schedule_item, schedule_item }
    end

    describe 'PUT #update' do
      let!(:schedule_item) { create :schedule_item, duration: 45 }

      context 'with valid attributes' do
        before :each do
          put :update, id: schedule_item.id, schedule_item: { duration: 60 }
        end

        it { expect(schedule_item.reload.duration).to eq 60 }
        it { is_expected.to redirect_to focus_schedule_item_path(ScheduleItem.last) }
      end

      context 'with invalid attributes' do
        before :each do
          put :update, id: schedule_item.id, schedule_item: { duration: -4 }
        end

        it { expect(schedule_item.reload.duration).to eq 45 }
        it { is_expected.to render_template :edit }
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        let!(:fitness_class) { create :fitness_class }
        let!(:trainer) { create :trainer }
        let!(:room) { create :room }

        subject { post :create, schedule_item: attributes_for(
          :schedule_item,
          fitness_class_id: fitness_class.id,
          room_id: room.id,
          trainer_id: trainer.id
        ) }

        it { expect { subject }.to change(ScheduleItem, :count).by(1) }
        it { is_expected.to redirect_to focus_schedule_item_path(ScheduleItem.last) }
      end

      context 'with invalid attributes' do
        subject { post :create, schedule_item: { trainer: '' } }

        it { expect { subject }.not_to change(ScheduleItem, :count) }
        it { is_expected.to render_template :new }
      end
    end

    describe 'DELETE #destroy' do
      let!(:schedule_item) { create :schedule_item }
      subject { xhr :delete, :destroy, id: schedule_item.id }

      it { expect { subject }.to change(ScheduleItem, :count).by(-1) }
      it { is_expected.to render_template :destroy }

      it 'sets notice' do
        subject
        expect(controller).to set_flash.now[:notice].to 'Schedule item has been deleted!'
      end
    end
  end
end