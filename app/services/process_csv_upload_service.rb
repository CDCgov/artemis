# FIXME: this service mutates class variables in the subsequent CSV records. It
# will likely break down for concurrent requests.
require "csv"
class ProcessCsvUploadService < ApplicationService
  attr_reader :nbs_data, :ovrs_data
  def call!(datasets = { nbs: nil, ovrs: nil })
    @nbs_data, @ovrs_data = datasets[:nbs], datasets[:ovrs]

    validate_nbs!
    validate_ovrs!

    NBS::NewbornRecord.load(nbs_data)
    OVRS::NewbornRecord.load(ovrs_data)

    true
  end

  private

  def validate_nbs!
    @nbs_column_names = ["NAME","BABYS_LAST_NAME","BABYS_FIRST_NAME","BIRTHDATE","BABYS_SEX","MOTHERS_LAST_NAME","MOTHERS_BIRTHDATE","BIRTH_WEIGHT","MULTIPLE_BIRTH","BIRTH_LENGTH"]
    @nbs_data_columns = CSV.parse(@nbs_data)[0]
    raise 'NBS data not present' unless @nbs_data_columns.sort == @nbs_column_names.sort#.subset? @main_set
  end

  def validate_ovrs!
    @ovrs_column_names = ["StateFileNumber","NewbornScreeningNumber","ChildLast","ChildFirst","BirthCCYY","BirthMM","BirthDD","Gender","MomLast","MomBirthCCYY","MomBirthMM","MomBirthDD","BirthWeightGrams","Plurality","ChildLengthCm"]
    @ovrs_data_columns = CSV.parse(@ovrs_data)[0]
    raise 'OVRS data not present' unless @ovrs_data_columns.sort == @ovrs_column_names.sort
  end
end
