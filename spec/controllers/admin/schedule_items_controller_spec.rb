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

      it { is_expected.to render_template :index }
      it { expect(controller.schedule_items).to match_array schedule_items }
    end
  end
end