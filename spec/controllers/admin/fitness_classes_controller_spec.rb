require 'rails_helper'

RSpec.describe Admin::FitnessClassesController do
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
        expect { post :create, fitness_class: build(:fitness_class) }.to require_admin_privileges
      end
    end

    describe 'PUT #update' do
      it 'raises an error' do
        expect { put :update, id: create(:fitness_class), fitness_class: attributes_for(:fitness_class) }.to require_admin_privileges
      end
    end

    describe 'DELETE #destroy' do
      it 'raises an error' do
        expect { delete :destroy, id: create(:fitness_class) }.to require_admin_privileges
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
      let!(:fitness_classes) { create_list(:fitness_class, 3) }
      subject { get :index }

      it { is_expected.to render_template :index }
      it 'exposes schedule items' do
        expect(controller.fitness_classes).to match_array fitness_classes
      end
    end

    describe 'GET #edit' do
      let!(:fitness_class) { create(:fitness_class) }
      subject { get :edit, id: fitness_class.id }

      it { is_expected.to render_template :edit }
    end

    describe 'PUT #update' do
      let!(:fitness_class) { create(:fitness_class, name: 'Zumba') }

      before :each do
        put :update, id: fitness_class.id, fitness_class: { name: 'Zumba Step' }
      end

      it 'updates fitness class attributes' do
        expect(fitness_class.reload.name).to eq 'Zumba Step'
      end
    end

    describe 'POST #create' do
      subject { post :create, fitness_class: attributes_for(:fitness_class) }

      it { expect { subject }.to change(FitnessClass, :count).by(1) }
    end

    describe 'DELETE #destroy' do
      let!(:fitness_class) { create(:fitness_class) }
      subject { delete :destroy, id: fitness_class.id }

      it { expect { subject }.to change(FitnessClass, :count).by(-1) }
    end
  end
end