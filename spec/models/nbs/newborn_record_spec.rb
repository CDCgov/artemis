require 'rails_helper'

RSpec.describe NBS::NewbornRecord, type: :model do
  before { described_class.reload }

  it 'correctly loads the records from the CSV file' do
    expect(described_class.count).to eq 100

    first = described_class.first
    expect(first.attributes).to eq(
      id: 'UT850A001',
      birth_length: 27,
      birth_weight: 3255,
      birthdate: Date.new(2015, 3, 2),
      first_name: nil,
      kit: 'UT850A001',
      last_name: nil,
      mothers_birthdate: Date.new(2000, 1, 1),
      mothers_first_name: nil,
      mothers_last_name: 'Kirk',
      multiple_birth: 1,
      sex: 'M'
    )
  end

  describe '.collection_cache_key' do
    it 'returns a cacheable string' do
      expect(described_class.collection_cache_key).to match %r{NBS\/\d+}
    end
  end

  describe '.match' do
    it 'finds a record by :kit' do
      match = described_class.match kit: 'UT850A093'
      expect(match.last_name).to eq 'Days'
    end

    it 'finds a record by :first_name, :last_name' do
      match = described_class.match first_name: 'Early', last_name: 'Days'
      expect(match.id).to eq 'UT850A093'
    end

    it 'returns nil if there are no matches' do
      expect(described_class.match(kit: '__missing__')).to be_nil
    end
  end

  describe '#match' do
    it 'delegates to the class method' do
      others = double
      expect(described_class).to receive(:match).with(subject, others)
      subject.match others
    end
  end
end
