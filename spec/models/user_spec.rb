require 'rails_helper'

RSpec.describe User do
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

  describe 'scopes' do
    describe '#without_reservation' do
      let!(:users) { create_list(:user, 3) }
      let!(:reservation) { create(:reservation, user: users[0]) }

      subject { described_class.without_reservation(reservation.schedule_item) }

      it 'lists users that do not have reservations for a given schedule item' do
        is_expected.to match_array users[1,2]
      end
    end
  end
end
