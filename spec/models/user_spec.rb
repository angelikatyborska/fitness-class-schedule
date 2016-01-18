require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
  end

  describe 'associations' do
    it { is_expected.to have_many :reservations }
    it { is_expected.to have_many :schedule_items }
  end
end
