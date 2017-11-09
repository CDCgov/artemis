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

  describe '#to_fhir' do
    let(:record) { described_class.find('UT850A020') }
    # UT850A020, Adams, John, 3/25/2015, M, Adams , 7/1/1977, 2807, 1, 24
    let(:fhir_patient) { record.to_fhir }

    it 'returns a FHIR Patient' do
      expect(record.to_fhir).to be_a(FHIR::Patient)
    end

    it 'uses the record ID as the identifier' do
      expect(fhir_patient.identifier[0].value).to eq(record[:id])
      expect(fhir_patient.identifier[0].use).to eq('official')
    end

    it 'fills in the given name' do
      expect(fhir_patient.name[0].given[0]).to eq(record[:first_name])
    end

    it 'fills in the family name' do
      expect(fhir_patient.name[0].family).to eq(record[:last_name])
    end

    it 'fills in the birth date' do
      expect(fhir_patient.birthDate).to eq(record[:birthdate])
    end

    it 'fills in the multiple birth integer value' do
      expect(fhir_patient.multipleBirthInteger).to eq(record[:multiple_birth])
    end

    context 'gender is mapped properly when gender is' do
      before(:each) do
        allow(record).to receive(:[]).and_call_original
        allow(record).to receive(:[]).with(:sex).and_return(sex)
      end

      context 'female' do
        let(:sex) { 'F' }

        it 'fills in the gender' do
          expect(fhir_patient.gender).to eq('female')
        end
      end

      context 'male' do
        let(:sex) { 'M' }

        it 'fills in the gender' do
          expect(fhir_patient.gender).to eq('male')
        end
      end

      context 'missing' do
        let(:sex) { nil }

        it 'fills in the gender' do
          expect(fhir_patient.gender).to eq('unknown')
        end
      end
    end
  end
end
