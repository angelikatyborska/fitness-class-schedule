require 'rails_helper'

RSpec.describe Admin::ScheduleItemsController do
  let(:admin) { create :admin_user }

  before { sign_in admin }

  describe 'GET #index' do
    let!(:schedule_items) { create_list(:schedule_item, 3) }
    subject { get :index }

    it { is_expected.to render_template :index }
    it { expect(controller.schedule_items).to match_array schedule_items }
  end
end