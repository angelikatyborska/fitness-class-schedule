require 'rails_helper'

RSpec.describe ScheduleItem do
  include ApplicationHelper

  describe 'validations' do
    it { is_expected.to validate_presence_of :trainer }
    it { is_expected.to validate_presence_of :room }
    it { is_expected.to validate_presence_of :start }
    it { is_expected.to validate_presence_of :fitness_class }
    it { is_expected.to validate_presence_of :duration }
    it { is_expected.to validate_numericality_of(:duration).is_greater_than(0) }
    it { is_expected.to validate_presence_of :capacity }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }

    context 'with start date in the past' do
      subject { build :schedule_item, start: ScheduleItem.beginning_of_day(Time.zone.now - 1.day) }

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:start]).to include('can\'t be in the past')
      end
    end

    context 'with a room that is already occupied' do
      let!(:room) { create :room }
      let!(:schedule_item_occupying_the_room) { create(
        :schedule_item,
        room: room,
        start: ScheduleItem.beginning_of_day(Time.zone.now + 1.day), duration: 60
      ) }

      subject { build(
        :schedule_item,
        room: room,
        start: ScheduleItem.beginning_of_day(Time.zone.now + 1.day) + 15.minutes
      ) }

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:room]).to include('is already occupied at this time')
      end
    end

    context 'with a trainer that is already occupied' do
      let!(:trainer) { create :trainer }
      let!(:schedule_item_occupying_the_room) { create(
        :schedule_item,
        trainer: trainer,
        start: ScheduleItem.beginning_of_day(Time.zone.now + 1.day),
        duration: 60
      ) }

      subject { build(
        :schedule_item,
        trainer: trainer,
        start: ScheduleItem.beginning_of_day(Time.zone.now + 1.day) + 15.minutes
      ) }

      it 'is not valid' do
        is_expected.not_to be_valid
        expect(subject.errors[:trainer]).to include('is already occupied at this time')
      end
    end
  end

  describe 'database columns' do
    it { is_expected.to have_db_column :start }
    it { is_expected.to have_db_column :duration }
    it { is_expected.to have_db_column :capacity }
    it { is_expected.to have_db_index :start }
    it { is_expected.to have_db_index :duration }
  end

  describe 'associations' do
    it { is_expected.to belong_to :trainer }
    it { is_expected.to belong_to :room }
    it { is_expected.to belong_to :fitness_class }
    it { is_expected.to have_many :reservations }
  end

  describe '#destroy' do
    let!(:schedule_item) { create :schedule_item, capacity: 2 }
    let!(:reservations) { create_list :reservation, 4, schedule_item: schedule_item }

    subject { schedule_item.destroy }

    context 'destroyed before start' do
      it 'sends an email to every user that has a reservation' do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(reservations.count)

        expected_emails = reservations.map { |reservation| [reservation.user.email] }

        n = reservations.count
        actual_emails = ActionMailer::Base.deliveries[ (-1 * n), n].map(&:to)

        expect(actual_emails).to match_array expected_emails
      end
    end

    context 'destroyed after start' do
      after :all do
        Timecop.return
      end

      it 'does not send emails' do
        Timecop.freeze(schedule_item.start + 5.minutes)
        expect { subject }.not_to change {
          ActionMailer::Base.deliveries.count
        }
      end
    end
  end

  describe '#update' do
    let!(:schedule_item) { create :schedule_item, capacity: 2 }
    let!(:reservations) { create_list :reservation, 4, schedule_item: schedule_item }

    context 'data changed' do
      subject { schedule_item.update!(
        capacity: 5,
        trainer: create(:trainer),
        room: create(:room),
        start: schedule_item.start + 3.days
      ) }

      it 'sends an email to every user that has a reservation' do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(reservations.count)

        expected_emails = reservations.map { |reservation| [reservation.user.email] }

        n = reservations.count
        actual_emails = ActionMailer::Base.deliveries[ (-1 * n), n].map(&:to)

        expect(actual_emails).to match_array expected_emails
      end
    end

    context 'data did not change' do
      subject { schedule_item.update!(
        capacity: schedule_item.capacity,
        trainer: schedule_item.trainer,
        room: schedule_item.room,
        start: schedule_item.start
      ) }

      it 'does not send emails' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end

  describe 'scopes' do
    describe '#week' do
      let!(:today) { Time.zone.now }
      let!(:this_week_items) { create_list :schedule_item_this_week, 2 }
      let!(:next_week_items) { create_list :schedule_item_next_week, 2 }

      before :all do
        Timecop.freeze(Time.zone.now.beginning_of_week)
      end

      after :all do
        Timecop.return
      end

      context 'without argument' do
        subject { described_class.week }

        it 'lists all schedule items starting this week' do
          is_expected.to include *(this_week_items)
          is_expected.not_to include *(next_week_items)
        end
      end

      context 'with next week\'s date' do
        subject { described_class.week(today + 7.days) }

        it 'lists all schedule items starting next week' do
          is_expected.not_to include *(this_week_items)
          is_expected.to include *(next_week_items)
        end
      end
    end

    describe '#hourly_time_frame' do
      let!(:schedule_item_at_3am) { create(
        :schedule_item,
        start: Time.zone.now.beginning_of_day + 1.day + 3.hours,
        duration: 45
      ) }

      let!(:schedule_item_at_8am) { create(
        :schedule_item,
        start: Time.zone.now.beginning_of_day + 1.day + 8.hours,
        duration: 45
      ) }

      let!(:schedule_item_at_10am) { create(
        :schedule_item,
        start: Time.zone.now.beginning_of_day + 1.day + 10.hours,
        duration: 45
      ) }

      it 'lists all schedule items that take place between given hours' do
        expect(described_class.hourly_time_frame(8, 12)).to match_array [schedule_item_at_8am, schedule_item_at_10am]
        expect(described_class.hourly_time_frame(12, 8)).to match_array [schedule_item_at_3am]

        expect(described_class.hourly_time_frame(8, 9)).to match_array [schedule_item_at_8am]
        expect(described_class.hourly_time_frame(9, 8)).to match_array [schedule_item_at_3am, schedule_item_at_10am]

        expect(described_class.hourly_time_frame(10, 12)).to match_array [schedule_item_at_10am]
        expect(described_class.hourly_time_frame(12, 10)).to match_array [schedule_item_at_3am, schedule_item_at_8am]
      end
    end

    describe '#trainer' do
      let!(:schedule_item) { create :schedule_item }
      let!(:other_schedule_item) { create :schedule_item }

      subject { described_class.trainer(schedule_item.trainer.id) }

      it 'lists all schedule items that belong to a trainer with the given id' do
        is_expected.to include schedule_item
        is_expected.not_to include other_schedule_item
      end
    end

    describe '#room' do
      let!(:schedule_item) { create :schedule_item }
      let!(:other_schedule_item) { create :schedule_item }

      subject { described_class.room(schedule_item.room.id) }

      it 'lists all schedule items that belong to a room with the given id' do
        is_expected.to include schedule_item
        is_expected.not_to include other_schedule_item
      end
    end

    describe '#active' do
      let!(:schedule_item_this_week) { create :schedule_item_this_week }
      let!(:schedule_item_next_week) { create :schedule_item_next_week }

      subject { described_class.active(Time.zone.now.end_of_week) }

      before :all do
        Timecop.freeze(Time.zone.now.beginning_of_week)
      end

      after :all do
        Timecop.return
      end

      it 'lists all schedule items that start no sooner than the given datetime' do
        is_expected.not_to include schedule_item_this_week
        is_expected.to include schedule_item_next_week
      end
    end

    describe '#stale' do
      let!(:schedule_item_this_week) { create :schedule_item_this_week }
      let!(:schedule_item_next_week) { create :schedule_item_next_week }

      subject { described_class.stale(Time.zone.now.end_of_week) }

      before :all do
        Timecop.freeze(Time.zone.now.beginning_of_week)
      end

      after :all do
        Timecop.return
      end

      it 'lists all schedule items that start no later than the given datetime' do
        is_expected.to include schedule_item_this_week
        is_expected.not_to include schedule_item_next_week
      end
    end
  end

  describe '#changes_without_timestamps_and_ids' do
    let!(:schedule_item) { create :schedule_item }

    subject { schedule_item.changes_without_timestamps_and_ids }

    before :each do
      schedule_item.room = (create :room)
      schedule_item.trainer = (create :trainer)
      schedule_item.fitness_class = (create :fitness_class)
    end

    it 'changes ids to associations' do
      associations = ['room', 'trainer', 'fitness_class']

      associations.each do |association|
        is_expected.not_to include association + '_id'
        is_expected.to include association

        expect(subject[association][0].class).to eq association.classify.constantize
        expect(subject[association][1].class).to eq association.classify.constantize
      end
    end

    it 'removes timestamps' do
      is_expected.not_to include 'created_at', 'updated_at'
    end
  end

  describe '#going_on_at?' do
    before :all do
      @now = Time.zone.now
      Timecop.freeze(Time.zone.now - 1.day)
    end

    after :all do
      Timecop.return
    end

    subject { schedule_item.going_on_at?(@now) }

    context 'with a schedule item that starts just now' do
      let!(:schedule_item) { create :schedule_item, start: @now, duration: 60 }

      it { is_expected.to eq true }
    end

    context 'with a schedule item that started 5 minutes before' do
      let!(:schedule_item) { create :schedule_item, start: @now - 5.minutes, duration: 60 }

      it { is_expected.to eq true }
    end

    context 'with a schedule item that started 3 hours before' do
      let!(:schedule_item) { create :schedule_item, start: @now - 3.hours, duration: 60 }

      it { is_expected.to eq false }
    end

    context 'with a schedule item that starts tomorrow' do
      let!(:schedule_item) { create :schedule_item, start: ScheduleItem.beginning_of_day(@now + 1.day), duration: 60 }

      it { is_expected.to eq false }
    end
  end

  describe '#going_on_between?' do
    let(:tomorrow) { ScheduleItem.beginning_of_day(Time.zone.now + 1.day) }
    let(:schedule_item) { build :schedule_item, start: tomorrow, duration: 60 }

    context 'a time period ending before item start' do
      subject { schedule_item.going_on_between?(tomorrow - 2.hours, tomorrow - 1.hour) }

      it { is_expected.to eq false }
    end

    context 'a time period starting after item start and ending before item end' do
      subject { schedule_item.going_on_between?(tomorrow + 5.minutes, tomorrow + 10.minutes) }

      it { is_expected.to eq true }
    end

    context 'a time period starting after item start and ending after item end' do
      subject { schedule_item.going_on_between?(tomorrow + 5.minutes, tomorrow + 1.hour) }

      it { is_expected.to eq true }
    end

    context 'a time period starting after item end' do
      subject { schedule_item.going_on_between?(tomorrow + 2.hours, tomorrow + 3.hours) }

      it { is_expected.to eq false }
    end
  end

  describe '#stop' do
    let!(:schedule_item) { create :schedule_item, duration: 45 }

    subject { schedule_item.stop }

    it { is_expected.to eq schedule_item.start + 45.minutes }
  end

  describe '#full?' do
    let!(:schedule_item) { create :schedule_item, capacity: 2 }

    subject { schedule_item.full? }

    context 'when schedule item has free spots' do
      it { is_expected.to eq false }
    end

    context 'when schedule item has no spots' do
      let!(:reservations) { create_list :reservation, 2, schedule_item: schedule_item }

      it { is_expected.to eq true }
    end
  end

  describe '#spots_left' do
    let!(:schedule_item) { create :schedule_item, capacity: 2 }

    it 'with every reservation made decreases down to zero' do
      expect(schedule_item.free_spots).to eq 2

      create :reservation, schedule_item: schedule_item
      expect(schedule_item.free_spots).to eq 1

      create :reservation, schedule_item: schedule_item
      expect(schedule_item.free_spots).to eq 0

      create :reservation, schedule_item: schedule_item
      expect(schedule_item.free_spots).to eq 0
    end
  end

  describe 'class methods' do
    describe '.beginning_of_day' do
      let(:today) { Time.zone.now }
      subject { described_class.beginning_of_day(today) }

      it 'returns the earliest time a schedule item starting at will be displayed' do
        expect(subject.hour).to eq SiteSettings.instance.day_start
        expect(subject.min).to eq 0
      end
    end

    describe '.end_of_day' do
      let(:today) { Time.zone.now }
      subject { described_class.end_of_day(today) }

      it 'returns the latest time a schedule item starting at will be displayed' do
        expect(subject.hour).to eq SiteSettings.instance.day_end - 1
        expect(subject.min).to eq 59
        expect(subject.sec).to eq 59
      end
    end
  end
end