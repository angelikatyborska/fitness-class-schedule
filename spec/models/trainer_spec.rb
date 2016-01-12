require 'rails_helper'

RSpec.describe Trainer do
  it_behaves_like 'occupiable', :trainer

  describe 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :description }
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :photo }
  end

  describe 'associations' do
    it { is_expected.to have_many :schedule_items }
  end
end