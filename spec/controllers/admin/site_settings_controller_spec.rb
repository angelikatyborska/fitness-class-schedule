require 'rails_helper'

RSpec.describe Admin::SiteSettingsController do
  shared_examples 'access denied' do
    describe 'GET #edit' do
      subject(:request) { get :edit }

      it { expect { request }.to require_admin_privileges }
    end

    describe 'PUT #update' do
      subject(:request) { put :update, site_settings: attributes_for(:site_settings) }

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

    describe 'GET #edit' do
      subject(:request) { get :edit }

      it { is_expected.to render_template :edit }
      it { is_expected.to expose :site_settings, SiteSettings.instance }
    end

    describe 'PUT #update' do
      context 'with valid attributes' do
        subject(:request) { put :update, site_settings: { time_zone: 'Hawaii', site_title: 'Totally new title' } }

        it { is_expected.to redirect_to edit_admin_site_settings_path }

        it 'changes site settings' do
          subject
          expect(SiteSettings.instance.time_zone).to eq 'Hawaii'
          expect(SiteSettings.instance.site_title).to eq 'Totally new title'
        end
      end

      context 'with invalid attributes' do
        subject(:request) { put :update, site_settings: { time_zone: 'not a time zone', site_title: 'A valid title' } }

        it { is_expected.to render_template :edit }

        it 'does not change site settings' do
          old_tme_zone = SiteSettings.instance.time_zone
          old_site_title = SiteSettings.instance.site_title
          subject
          expect(SiteSettings.instance.time_zone).to eq old_tme_zone
          expect(SiteSettings.instance.site_title).to eq old_site_title
        end
      end
    end
  end
end