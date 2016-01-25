require 'carrierwave/test/matchers'

RSpec.describe TrainerPhotoUploader do
  include CarrierWave::Test::Matchers

  let!(:trainer) { create :trainer, first_name: 'Ann', last_name: 'Smith' }

  before do
    described_class.enable_processing = true
    @uploader = described_class.new(trainer, :photo)
    @uploader.store!(Rails.root.join('spec', 'support', 'images', 'trainer.png').open)
  end

  after do
    described_class.enable_processing = false
    @uploader.remove!
  end

  it 'should rename the file to trainer\'s names' do
    expect(@uploader.filename).to eq 'ann_smith.jpg'
  end

  it 'should make the image readable to all and writable only by owner' do
    @uploader.should have_permissions(0644)
  end
end