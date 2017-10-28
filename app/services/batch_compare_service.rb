class BatchCompareService < ApplicationService
  attr_reader :datasets, :hierarchy

  def initialize(options = {
    datasets:  [NBS::NewbornRecord.all, OVRS::NewbornRecord.all],
    hierarchy: %i[
      kit
      birthdate
      mothers_birthdate
      mothers_last_name
      mothers_first_name
      sex
      last_name
      first_name
      multiple_birth
      birth_weight
      birth_length
    ],
    requestor: 'system'
  })
    raise ArgumentError unless options[:datasets].length == 2
    @datasets       = options[:datasets]
    @hierarchy      = options[:hierarchy]
    @requestor      = options[:requestor]
  end

  def call!
    Report.create! requestor: @requestor,
                   data: { conflicts: conflicts },
                   type: 'DiscrepancyReport'
  end

  private

  def choose_id(*records)
    uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/ # rubocop:disable Metrics/LineLength
    ids = records.map(&:id).compact
    without_uuid = ids.reject { |id| uuid_regex.match?(id) }
    without_uuid.empty? ? ids.first : without_uuid.first
  end

  def compare(record, other)
    difference = record.attributes.to_a - other.attributes.to_a
    Hash[*difference.flatten]
  end

  def conflicts
    conflicts = Hash.new { |hash, key| hash[key] = Set.new }
    datasets.permutation.each do |control, other|
      control.each do |record|
        linked = record.match other
        diffs = linked ? compare(record, linked) : []
        diffs.each_key { |prop| conflicts[choose_id(record, linked)].add(prop) }
      end
    end
    conflicts
  end
end
