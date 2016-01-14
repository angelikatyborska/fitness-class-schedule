require 'rails_helper'

RSpec.describe RoomPhoto do
  describe 'validations' do
    it { is_expected.to validate_presence_of :photo }
    it { is_expected.to validate_presence_of :room }
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :photo }
  end

  describe 'associations' do
    it { is_expected.to belong_to :room }
  end
end
