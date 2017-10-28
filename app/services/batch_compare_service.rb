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
        linked = find(record, other)
        diffs = linked ? compare(record, linked) : []
        diffs.each_key { |prop| conflicts[choose_id(record, linked)].add(prop) }
      end
    end
    conflicts
  end

  def find(record, matches = [], fields = hierarchy) # rubocop:disable Metrics/AbcSize, Metrics/LineLength
    # TODO: implement an efficient record-linkage algorithm
    # NOTE: maybe see https://github.com/coupler/linkage for inspiration

    # Base case
    return (matches.length == 1 ? matches.first : nil) if fields.empty?

    # Recursive case
    field, *fields = fields
    value = record.send(field)

    # Early return if value is nil
    return find(record, matches, fields) unless value

    # Reduce values
    # NOTE: ActiveHash cannot chain #where, unfortunately, so we cast to Array
    maybe_matches = matches.to_a.select { |other| other.send(field) == value }
    return find(record, matches, fields) if maybe_matches.empty?

    # Early return if one match found
    return maybe_matches.first if maybe_matches.length == 1

    find(record, maybe_matches, fields)
  end
end
