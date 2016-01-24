require 'rails_helper'

RSpec.describe ReservationMailer, type: :mailer do
  describe '#spot_freed' do
    let(:reservation) { create(:reservation) }
    let(:mail) { described_class.spot_freed(reservation)}

    it 'renders the subject' do
      expect(mail.subject).to eq "There is an empty spot for you at #{ reservation.schedule_item }, #{ I18n.l(reservation.schedule_item.start, format: :human_friendly_date_with_weekday) }"
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq [reservation.user.email]
    end

    it 'renders the sender email' do
      expect(mail.from).to eq [Configurable.email]
    end

    it 'mentions most important information' do
      expect(mail.body.encoded).to have_content 'Good news!'
      expect(mail.body.encoded).to have_content reservation.schedule_item
      expect(mail.body.encoded).to have_content I18n.l(reservation.schedule_item.start, format: :human_friendly_date_with_weekday)
      expect(mail.body.encoded).to have_content I18n.l(reservation.schedule_item.start, format: :simple_time)
    end
  end
end
