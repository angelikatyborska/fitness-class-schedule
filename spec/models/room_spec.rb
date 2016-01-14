require 'rails_helper'

RSpec.describe Room do
  it_behaves_like 'occupiable', :room

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description }
  end

  describe 'associations' do
    it { is_expected.to have_many :schedule_items }
    it { is_expected.to have_many :room_photos }
  end
end
