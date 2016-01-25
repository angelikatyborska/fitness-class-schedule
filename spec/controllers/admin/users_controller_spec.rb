require 'rails_helper'

RSpec.describe Admin::UsersController do
  shared_examples 'access denied' do
    let!(:user) { create :user }

    describe 'GET #show' do
      it 'raises an error' do
        expect { get :show, id: user.id }.to require_admin_privileges
      end
    end

    describe 'GET #edit' do
      it 'raises an error' do
        expect { get :edit, id: user.id }.to require_admin_privileges
      end
    end

    describe 'PUT #update' do
      it 'raises an error' do
        expect { put :update, id: user.id }.to require_admin_privileges
      end
    end

    describe 'DELETE #destroy' do
      it 'raises an error' do
        expect { delete :destroy, id: user.id }.to require_admin_privileges
      end
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

      it 'renders template show' do
        is_expected.to render_template :show
      end
    end

    describe 'GET #edit' do
      subject { get :edit, id: user.id }

      it 'renders template edit' do
        is_expected.to render_template :edit
      end
    end

    describe 'PUT #update' do
      context 'with valid attributes' do
        before :each do
          put :update, id: user.id, user: { first_name: 'Robert' }
        end

        it 'updates user attributes' do
          expect(user.reload.first_name).to eq 'Robert'
        end

        it 'redirects to index with a notice' do
          is_expected.to redirect_to action: :index, anchor: user.decorate.css_id
          expect(controller).to set_flash[:notice].to 'User has been updated!'
        end
      end

      context 'with invalid attributes' do
        before :each do
          put :update, id: user.id, user: { first_name: '' }
        end

        it 'does not update attributes' do
          expect(user.reload.first_name).to eq 'Bob'
        end

        it { is_expected.to render_template :edit }
      end
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: user.id }

      it 'deletes the user' do
        expect { subject }.to change(User, :count).by(-1)
      end

      it 'redirects to index with a notice' do
        is_expected.to redirect_to action: :index
        expect(controller).to set_flash[:notice].to 'User has been deleted!'
      end
    end
  end
end