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

  describe 'fhir_elements' do
    let(:record) { described_class.find('UT850A020') }
    # UT850A020, Adams, John, 3/25/2015, M, Adams , 7/1/1977, 2807, 1, 24
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

    describe '#save_to_fhir' do
      let(:client)      { double FHIR::Client }
      let(:length_id)   { 'length-id' }
      let(:length_obs)  { double FHIR::Observation, id: length_id, save: nil }
      let(:mother_id)   { 'mother-id' }
      let(:mother)      { double FHIR::RelatedPerson, id: mother_id }
      let(:patient_id)  { 'patient-id' }
      let(:patient)     { double FHIR::Patient, id: patient_id }
      let(:weight_id)   { 'weight-id' }
      let(:weight_obs)  { double FHIR::Observation, id: weight_id }

      before(:each) do
        allow(client).to receive(:begin_transaction)
        allow(client).to receive(:add_transaction_request)
        allow(client).to receive(:end_transaction)
        allow(record).to receive(:birth_length_observation).and_return(length_obs)
        allow(record).to receive(:birth_weight_observation).and_return(weight_obs)
        allow(record).to receive(:mother_info).and_return(mother)
        allow(record).to receive(:patient_object).and_return(patient)
        allow(record).to receive(:add_mother_to_patient)
      end

      it 'creates the patient record' do
        expect(record).to receive(:patient_object).and_call_original
        record.save_to_fhir client
      end

      it 'creates the mother record' do
        expect(record).to receive(:mother_info).and_call_original
        record.save_to_fhir client
      end

      it 'creates the length observation' do
        expect(record).to receive(:birth_length_observation).and_call_original
        record.save_to_fhir client
      end

      it 'creates the weight observation' do
        expect(record).to receive(:birth_weight_observation).and_call_original
        record.save_to_fhir client
      end

      it 'saves the objects' do
        expect(client).to receive(:begin_transaction)
        expect(record).to receive(:add_mother_to_patient).with(mother, patient)
        expect(client).to receive(:add_transaction_request).with('POST', nil, patient)
        expect(client).to receive(:add_transaction_request).with('POST', nil, mother)
        expect(client).to receive(:add_transaction_request).with('POST', nil, length_obs)
        expect(client).to receive(:add_transaction_request).with('POST', nil, weight_obs)
        expect(client).to receive(:end_transaction)
        record.save_to_fhir client
      end
    end
  end
end
