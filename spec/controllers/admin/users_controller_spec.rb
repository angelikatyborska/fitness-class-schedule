require 'rails_helper'

RSpec.describe Admin::UsersController do
  shared_examples 'access denied' do
    let!(:user) { create :user }

    describe 'GET #show' do
      subject(:request) { get :show, id: user.id }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'GET #edit' do
      subject(:request) { get :edit, id: user.id }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'PUT #update' do
      subject(:request) { put :update, id: user.id }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'DELETE #destroy' do
      subject(:request) { delete :destroy, id: user.id }

      it { expect { request }.to require_admin_privileges }
    end
  end

  describe 'guest access' do
    it_behaves_like 'access denied'
  end

  describe 'user access' do
    let!(:user) { create :user }

    before { sign_in user }

    it_behaves_like 'access denied'
  end

  describe 'admin access' do
    let!(:admin) { create :admin_user }
    let!(:user) { create :user, first_name: 'Bob' }

    before { sign_in admin }

    describe 'GET #show' do
      subject { get :show, id: user.id }

      it { is_expected.to render_template :show }
    end

    describe 'GET #edit' do
      subject { get :edit, id: user.id }

      it { is_expected.to render_template :edit }
    end

    describe 'PUT #update' do
      context 'with valid attributes' do
        before :each do
          put :update, id: user.id, user: { first_name: 'Robert' }
        end

        it { expect(user.reload.first_name).to eq 'Robert' }

        it 'redirects to index with a notice' do
          is_expected.to redirect_to action: :index, anchor: user.decorate.css_id
          expect(controller).to set_flash[:notice].to 'User has been updated!'
        end
      end

      context 'with invalid attributes' do
        before :each do
          put :update, id: user.id, user: { first_name: '' }
        end

        it { expect(user.reload.first_name).to eq 'Bob' }
        it { is_expected.to render_template :edit }
      end
    end

    describe 'DELETE #destroy' do
      subject { xhr :delete, :destroy, id: user.id }

      it { expect { subject }.to change(User, :count).by(-1) }
      it { is_expected.to render_template :destroy }

      it 'sets notice' do
        subject
        expect(controller).to set_flash.now[:notice].to 'User has been deleted!'
      end
    end
  end
end