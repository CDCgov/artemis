require 'rails_helper'

RSpec.describe OVRS::NewbornRecord, type: :model do
  before { described_class.reload }

  describe '.collection_cache_key' do
    it 'returns a cacheable string' do
      expect(described_class.collection_cache_key).to match /ovrs\/\d+/
    end
  end

  it 'correctly loads the records from the CSV file' do
    expect(described_class.count).to eq 100

    first = described_class.first
    expect(first.attributes).to eq(
      id: 'UT850A001',
      birth_length: 27,
      birth_weight: 3255,
      birthdate: Date.new(2015, 3, 2),
      first_name: 'James',
      kit: 'UT850A001',
      last_name: 'Kirk',
      mothers_birthdate: Date.new(2000, 1, 1),
      mothers_first_name: nil,
      mothers_last_name: 'Kirk',
      multiple_birth: 1,
      sex: 'M'
    )
  end

end
