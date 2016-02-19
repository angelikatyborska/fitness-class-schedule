require 'rails_helper'

RSpec.describe SiteSettings do
  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:singleton_guard).in_array([0]) }
    it { is_expected.to validate_inclusion_of(:day_start).in_array((0..23).to_a) }
    it { is_expected.to validate_inclusion_of(:day_end).in_array((1..24).to_a) }
    it { is_expected.to validate_inclusion_of(:time_zone).in_array(ActiveSupport::TimeZone.all.map(&:name)) }
  end

  describe 'database columns' do
    it { is_expected.to have_db_column(:singleton_guard).of_type(:integer) }

    it { is_expected.to have_db_column(:day_start).of_type(:integer) }
    it { is_expected.to have_db_column(:day_end).of_type(:integer) }
    it { is_expected.to have_db_column(:time_zone).of_type(:string) }
    it { is_expected.to have_db_column(:cancellation_deadline).of_type(:integer) }

    it { is_expected.to have_db_column(:site_title).of_type(:string) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
  end

  describe 'default values' do
    before :each do
      described_class.instance.destroy
    end

    subject { described_class.instance }

    it { expect(subject.day_start).to eq 8 }
    it { expect(subject.day_end).to eq 23 }
    it { expect(subject.time_zone).to eq 'Warsaw' }
    it { expect(subject.cancellation_deadline).to eq 12 }
    it { expect(subject.site_title).to eq 'My Fitness Club' }
    it { expect(subject.email).to eq 'noreply@example.com' }
  end

  describe 'caching' do
    before :each do
      described_class.instance.destroy
    end

    it 'return an old value when not saved' do
      described_class.instance.day_start = 10
      expect(described_class.instance.day_start).to eq 8
    end

    it 'returns the new value when saved' do
      settings = described_class.instance
      settings.day_start = 10
      settings.save!

      expect(described_class.instance.day_start).to eq 10
    end

    it 'returns the default value when destroyed' do
      settings = described_class.instance
      settings.day_start = 10
      settings.save!
      settings.destroy

      expect(described_class.instance.day_start).to eq 8
    end
  end

  describe '.instance' do
    before :each do
      described_class.instance.destroy
    end

    subject { described_class.instance }

    it 'always returns the same record' do
      id = subject.id

      10.times { expect(subject.id).to eq id }
    end

    it 'creates a new record only on the first call' do
      expect{ subject }.to change(described_class, :count).from(0).to(1)
      expect{ subject }.not_to change(described_class, :count)
    end
  end
end