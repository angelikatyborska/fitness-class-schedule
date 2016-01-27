require 'rails_helper'

RSpec.describe Admin::TrainersController do
  shared_examples 'access denied' do
    describe 'GET #index' do
      subject(:request) { get :index }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'GET #new' do
      subject(:request) { get :new }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'GET #edit' do
      subject(:request) { get :edit, id: create(:trainer) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'POST #create' do
      subject(:request) { post :create, trainer: build(:trainer) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'PUT #update' do
      subject(:request) { put :update, id: create(:trainer), trainer: attributes_for(:trainer) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'DELETE #destroy' do
      subject(:request) { delete :destroy, id: create(:trainer) }

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
      let!(:trainers) { create_list :trainer, 3 }
      subject { get :index }

      it { is_expected.to render_template :index }
      it { is_expected.to expose :trainers, trainers }
    end

    describe 'GET #new' do
      subject { get :new }

      it { is_expected.to render_template :new }
    end

    describe 'GET #edit' do
      let!(:trainer) { create :trainer }
      subject { get :edit, id: trainer.id }

      it { is_expected.to render_template :edit }
      it { is_expected.to expose :trainer, trainer }
    end

    describe 'PUT #update' do
      let!(:trainer) { create :trainer, first_name: 'Ann' }

      context 'with valid attributes' do

        before :each do
          put :update, id: trainer.id, trainer: { first_name: 'Mary' }
        end

        it { expect(trainer.reload.first_name).to eq 'Mary' }

        it 'redirects to index with a notice' do
          is_expected.to redirect_to action: :index, anchor: Trainer.last.decorate.css_id
          expect(controller).to set_flash[:notice].to 'Trainer has been updated!'
        end
      end

      context 'with invalid attributes' do
        before :each do
          put :update, id: trainer.id, trainer: { first_name: '' }
        end

        it { expect(trainer.reload.first_name).to eq 'Ann' }
        it { is_expected.to render_template :edit }
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        subject { post :create, trainer: attributes_for(:trainer) }

        it { expect { subject }.to change(Trainer, :count).by(1) }

        it 'redirects to index with a notice' do
          is_expected.to redirect_to action: :index, anchor: Trainer.last.decorate.css_id
          expect(controller).to set_flash[:notice].to 'Trainer has been created!'
        end
      end

      context 'with invalid attributes' do
        subject { post :create, trainer: { first_name: '', description: ''} }

        it { expect { subject }.not_to change(Trainer, :count) }
        it { is_expected.to render_template :new }
      end
    end

    describe 'DELETE #destroy' do
      let!(:trainer) { create :trainer }
      subject { xhr :delete, :destroy, id: trainer.id }

      it { expect { subject }.to change(Trainer, :count).by(-1) }
      it { is_expected.to render_template :destroy }

      it 'sets notice' do
        subject
        expect(controller).to set_flash.now[:notice].to 'Trainer has been deleted!'
        end
    end
  end
end