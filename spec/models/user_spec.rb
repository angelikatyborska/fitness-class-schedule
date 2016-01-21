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
    describe 'default scope' do
      it 'includes reservations with schedule items' do
        expect(described_class.all.includes_values).to eq [reservations: [:schedule_item]]
      end
    end

    describe '#without_reservation' do
      let!(:users) { create_list(:user, 3) }
      let!(:reservation) { create(:reservation, user: users[0]) }

      subject { described_class.without_reservation(reservation.schedule_item) }

      it 'lists users that do not have reservations for a given schedule item' do
        is_expected.to match_array users[1,2]
      end
    end
  end

  describe '#reliability' do
    let!(:user) { create(:user) }

    subject { user.reliability }

    context 'without any reservations' do
      it 'returns 1' do
        is_expected.to eq 1
      end
    end

    context 'without any attended reservations' do
      let!(:missed_reservation) { create(:reservation, user: user, status: 'missed') }
      let!(:active_reservation) { create(:reservation, user: user, status: 'active') }

      it 'returns 0' do
        is_expected.to eq 0
      end
    end

    context 'with attended, missed and active reservations' do
      let!(:attended_reservation) { create(:reservation, user: user, status: 'attended') }
      let!(:missed_reservation) { create(:reservation, user: user, status: 'missed') }
      let!(:active_reservation) { create(:reservation, user: user, status: 'active') }

      it 'calculates the fraction of all past (attended or missed) reservations that were attended' do
        is_expected.to eq 0.5
      end
    end
  end
end
