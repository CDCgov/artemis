# FIXME: this service mutates class variables in the subsequent CSV records. It
# will likely break down for concurrent requests.
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
    # TODO: this should validate that uploaded NBS data has all the headers
    raise 'NBS data not present' unless @nbs_data
  end

  def validate_ovrs!
    # TODO: this should validate that uploaded OVRS data has all the headers
    raise 'OVRS data not present' unless @ovrs_data
  end
end
