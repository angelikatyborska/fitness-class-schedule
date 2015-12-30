require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many :reservations }
    it { is_expected.to have_many :schedule_items }
  end
end
