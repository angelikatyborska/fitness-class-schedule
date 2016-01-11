require 'rails_helper'

RSpec.describe FitnessClass do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of :name }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :color }
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :color }
  end

  describe 'associations' do
    it { is_expected.to have_many :schedule_items }
  end
end