require 'rails_helper'

RSpec.describe Room do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'associations' do
    it { is_expected.to have_many :schedule_items }
  end
end
