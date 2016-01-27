require 'rails_helper'

RSpec.describe Admin::FitnessClassesController do
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
      subject(:request) { post :create, fitness_class: build(:fitness_class) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'PUT #update' do
      subject(:request) { put :update, id: create(:fitness_class), fitness_class: attributes_for(:fitness_class) }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'DELETE #destroy' do
      subject(:request) { delete :destroy, id: create(:fitness_class) }

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
      let!(:fitness_classes) { create_list :fitness_class, 3 }
      subject { get :index }

      it { is_expected.to render_template :index }
      it { is_expected.to expose :fitness_classes, fitness_classes }
    end

    describe 'GET #new' do
      subject { get :new }

      it { is_expected.to render_template :new }
    end

    describe 'GET #edit' do
      let!(:fitness_class) { create :fitness_class }
      subject { get :edit, id: fitness_class.id }

      it { is_expected.to render_template :edit }
      it { is_expected.to expose :fitness_class, fitness_class }
    end

    describe 'PUT #update' do
      let!(:fitness_class) { create :fitness_class, name: 'Zumba' }

      context 'with valid attributes' do
        before :each do
          put :update, id: fitness_class.id, fitness_class: { name: 'Zumba Step' }
        end

        it { expect(fitness_class.reload.name).to eq 'Zumba Step' }

        it 'redirects to index with a notice' do
          is_expected.to redirect_to action: :index, anchor: FitnessClass.last.decorate.css_id
          expect(controller).to set_flash[:notice].to 'Class has been updated!'
        end
      end

      context 'with invalid attributes' do
        before :each do
          put :update, id: fitness_class.id, fitness_class: { name: '' }
        end

        it { expect(fitness_class.reload.name).to eq 'Zumba' }

        it { is_expected.to render_template :edit }
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        subject { post :create, fitness_class: attributes_for(:fitness_class) }

        it { expect { subject }.to change(FitnessClass, :count).by(1) }

        it 'redirects to index with a notice' do
          is_expected.to redirect_to action: :index, anchor: FitnessClass.last.decorate.css_id
          expect(controller).to set_flash[:notice].to 'Class has been created!'
        end
      end

      context 'with invalid attributes' do
        subject { post :create, fitness_class: { name: '', description: ''} }

        it { expect { subject }.not_to change(FitnessClass, :count) }
        it { is_expected.to render_template :new }
      end
    end

    describe 'DELETE #destroy' do
      let!(:fitness_class) { create :fitness_class }
      subject { xhr :delete, :destroy, id: fitness_class.id }

      it { expect { subject }.to change(FitnessClass, :count).by(-1) }
      it { is_expected.to render_template :destroy }

      it 'sets notice' do
        subject
        expect(controller).to set_flash.now[:notice].to 'Class has been deleted!'
      end
    end
  end
end