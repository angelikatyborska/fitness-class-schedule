require 'rails_helper'

RSpec.describe Admin::TrainersController do
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

    describe 'GET #edit' do
      it 'raises an error' do
        expect { get :edit, id: create(:trainer) }.to require_admin_privileges
      end
    end

    describe 'POST #create' do
      it 'raises an error' do
        expect { post :create, trainer: build(:trainer) }.to require_admin_privileges
      end
    end

    describe 'PUT #update' do
      it 'raises an error' do
        expect { put :update, id: create(:trainer), trainer: attributes_for(:trainer) }.to require_admin_privileges
      end
    end

    describe 'DELETE #destroy' do
      it 'raises an error' do
        expect { delete :destroy, id: create(:trainer) }.to require_admin_privileges
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
      let!(:trainers) { create_list :trainer, 3 }
      subject { get :index }

      it 'renders template index' do
        is_expected.to render_template :index
      end

      it 'exposes schedule items' do
        expect(controller.trainers).to match_array trainers
      end
    end

    describe 'GET #new' do
      subject { get :new }

      it 'renders template new' do
        is_expected.to render_template :new
      end
    end

    describe 'GET #edit' do
      let!(:trainer) { create :trainer }
      subject { get :edit, id: trainer.id }

      it 'renders template edit' do
        is_expected.to render_template :edit
      end

      it 'exposes trainer' do
        subject
        expect(controller.trainer).to eq trainer
      end
    end

    describe 'PUT #update' do
      let!(:trainer) { create :trainer, first_name: 'Ann' }

      before :each do
        put :update, id: trainer.id, trainer: { first_name: 'Mary' }
      end

      it 'updates trainer\s attributes' do
        expect(trainer.reload.first_name).to eq 'Mary'
      end

      it 'redirects to index with a notice' do
        is_expected.to redirect_to action: :index, anchor: Trainer.last.decorate.css_id
        expect(controller).to set_flash[:notice].to 'Trainer has been updated!'
      end
    end

    describe 'POST #create' do
      subject { post :create, trainer: attributes_for(:trainer) }

      it 'creates a trainer' do
        expect { subject }.to change(Trainer, :count).by(1)
      end

      it 'redirects to index with a notice' do
        is_expected.to redirect_to action: :index, anchor: Trainer.last.decorate.css_id
        expect(controller).to set_flash[:notice].to 'Trainer has been created!'
      end
    end

    describe 'DELETE #destroy' do
      let!(:trainer) { create :trainer }
      subject { delete :destroy, id: trainer.id }

      it 'deletes the trainer' do
        expect { subject }.to change(Trainer, :count).by(-1)
      end

      it 'redirects to index with a notice' do
        is_expected.to redirect_to action: :index
        expect(controller).to set_flash[:notice].to 'Trainer has been deleted!'
      end
    end
  end
end