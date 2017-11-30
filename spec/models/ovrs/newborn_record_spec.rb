require 'rails_helper'

RSpec.describe OVRS::NewbornRecord, type: :model do
  before { described_class.reload }

  describe '.collection_cache_key' do
    it 'returns a cacheable string' do
      expect(described_class.collection_cache_key).to match %r{OVRS\/\d+}
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

  describe '#fhir elements' do
    let(:record) { described_class.find('UT850A002') }
    # 2015  00135,UT850A002,Christmas,Merry,2015,12,8,F,Christmas,1985,1,8,2881,1,22
    let(:fhir_patient) { record.patient_object }

    describe '#patient_object' do
      it 'returns a FHIR Patient' do
        expect(record.patient_object).to be_a(FHIR::Patient)
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

    describe '#add_mother_to_patient' do
      let(:fhir_patient) { record.patient_object }
      let(:mother) { double('RelatedPerson', id: '12345') }

      it 'adds a reference to a RelatedPerson representing the mother' do
        record.add_mother_to_patient(mother, fhir_patient)
        expect(fhir_patient.link[0]).to be_a(FHIR::Patient::Link)
        expect(
          fhir_patient.link[0].other.reference
        ).to eq("RelatedPerson/#{mother.id}")
      end
    end

    describe '#mother_info' do
      let(:mother) { record.mother_info fhir_patient }

      it 'fills in the birthdate' do
        expect(mother.birthDate).to eq(record[:mothers_birthdate])
      end

      it 'fills in the family name' do
        expect(mother.name[0].family).to eq(record[:mothers_last_name])
      end

      it 'does not fill in a first name' do
        expect(mother.name[0].given).to be_empty
      end

      it 'links the mother to the patient' do
        expect(mother.patient).to be_a(FHIR::Reference)
        expect(mother.patient.reference).to eq("Patient/#{fhir_patient.id}")
      end
    end

    describe '#birth_length_observation' do
      let(:code) { '8305-5' }
      let(:observation) { record.birth_length_observation fhir_patient }
      it 'returns an observation' do
        expect(observation).to be_a(FHIR::Observation)
      end

      it 'links the observation to the patient' do
        expect(observation.subject).to be_a(FHIR::Reference)
        expect(observation.subject.reference).to eq("Patient/#{fhir_patient.id}")
      end

      it 'fills in the coding system and code' do
        expect(observation.code).to be_a(FHIR::CodeableConcept)
        expect(observation.code.coding[0]).to be_a(FHIR::Coding)
        expect(observation.code.coding[0].system).to eq('http://loinc.org')
        expect(observation.code.coding[0].code).to eq(code)
      end

      it 'fills in the birth length' do
        expect(observation.valueQuantity).to be_a(FHIR::Quantity)
        expect(observation.valueQuantity.unit).to eq('cm')
        expect(observation.valueQuantity.value).to eq(record[:birth_length])
      end
    end

    describe '#birth_weight_observation' do
      let(:code) { '56056-5' }
      let(:observation) { record.birth_weight_observation fhir_patient }
      it 'returns an observation for the birth weight' do
        expect(observation).to be_a(FHIR::Observation)
      end

      it 'links the observation to the patient' do
        expect(observation.subject).to be_a(FHIR::Reference)
        expect(observation.subject.reference).to eq("Patient/#{fhir_patient.id}")
      end

      it 'fills in the coding system and code' do
        expect(observation.code).to be_a(FHIR::CodeableConcept)
        expect(observation.code.coding[0]).to be_a(FHIR::Coding)
        expect(observation.code.coding[0].system).to eq('http://loinc.org')
        expect(observation.code.coding[0].code).to eq(code)
      end

      it 'fills in the birth length' do
        expect(observation.valueQuantity).to be_a(FHIR::Quantity)
        expect(observation.valueQuantity.unit).to eq('g')
        expect(observation.valueQuantity.value).to eq(record[:birth_weight])
      end
    end
  end
end
