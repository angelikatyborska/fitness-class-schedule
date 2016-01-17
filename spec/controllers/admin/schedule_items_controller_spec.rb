require 'rails_helper'

RSpec.describe Admin::ScheduleItemsController do
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
        expect { post :create, schedule_item: build(:schedule_item) }.to require_admin_privileges
      end
    end

    describe 'PUT #update' do
      it 'raises an error' do
        expect { put :update, id: create(:schedule_item), schedule_item: attributes_for(:schedule_item) }.to require_admin_privileges
      end
    end

    describe 'DELETE #destroy' do
      it 'raises an error' do
        expect { delete :destroy, id: create(:schedule_item) }.to require_admin_privileges
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
      let!(:schedule_items) { create_list(:schedule_item, 3) }
      subject { get :index }

      it 'renders template index' do
        is_expected.to render_template :index
      end

      it 'exposes schedule items' do
        expect(controller.schedule_items).to match_array schedule_items
      end
    end

    describe 'GET #edit' do
      let!(:schedule_item) { create(:schedule_item) }
      subject { get :edit, id: schedule_item.id }

      it 'renders template edit' do
        is_expected.to render_template :edit
      end
    end

    describe 'PUT #update' do
      let!(:schedule_item) { create(:schedule_item, duration: 45) }

      before :each do
        put :update, id: schedule_item.id, schedule_item: { duration: 60 }
      end

      it 'updates schedule item attributes' do
        expect(schedule_item.reload.duration).to eq 60
      end
    end

    describe 'POST #create' do
      let!(:fitness_class) { create(:fitness_class) }
      let!(:trainer) { create(:trainer) }
      let!(:room) { create(:room) }
      subject { post :create, schedule_item: attributes_for(:schedule_item, fitness_class_id: fitness_class.id, room_id: room.id, trainer_id: trainer.id) }

      it {
        expect { subject }.to change(ScheduleItem, :count).by(1)
      }
    end

    describe 'DELETE #destroy' do
      let!(:schedule_item) { create(:schedule_item) }
      subject { delete :destroy, id: schedule_item.id }

      it { expect { subject }.to change(ScheduleItem, :count).by(-1) }
    end
  end
end