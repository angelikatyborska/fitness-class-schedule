require 'rails_helper'

RSpec.shared_examples 'occupiable' do |model|
  describe '#occupied?' do
    let!(:time) { ScheduleItem.beginning_of_day(Time.zone.now + 2.days) + 2.hours }
    let!(:occupiable) { create(model) }

    context 'without schedule items' do
      it { expect(occupiable.occupied?(time, time + 30.minutes)).to eq false }
    end

    context 'with schedule items' do
      context 'starting before and ending before' do
        let!(:schedule_item) { create(:schedule_item, model => occupiable, start: time - 1.hours, duration: 30) }

        it { expect(occupiable.occupied?(time, time + 30.minutes)).to eq false }
      end

      context 'starting before and ending during' do
        let!(:schedule_item) { create(:schedule_item, model => occupiable, start: time - 1.hours, duration: 70) }

        it { expect(occupiable.occupied?(time, time + 30.minutes)).to eq true }
      end

      context 'starting and ending during' do
        let!(:schedule_item) { create(:schedule_item, model => occupiable, start: time + 5.minutes, duration: 20) }

        it { expect(occupiable.occupied?(time, time + 30.minutes)).to eq true }
      end

      context 'starting during and ending after' do
        let!(:schedule_item) { create(:schedule_item, model => occupiable, start: time + 5.minutes, duration: 60) }

        it { expect(occupiable.occupied?(time, time + 30.minutes)).to eq true }
      end

      context 'starting and ending after' do
        let!(:schedule_item) { create(:schedule_item, model => occupiable, start: time + 1.hour, duration: 60) }

        it { expect(occupiable.occupied?(time, time + 30.minutes)).to eq false }
      end
    end
  end
end