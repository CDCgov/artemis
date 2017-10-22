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
    ]
  })
    raise ArgumentError unless options[:datasets].length == 2
    @datasets = options[:datasets]
    @hierarchy = options[:hierarchy]
  end

  def call!
    conflicts = Hash.new { |hash, key| hash[key] = Set.new }
    datasets.permutation.each do |control, other|
      control.each do |record|
        linked = find(record, other)
        differences = linked ? compare(record, linked) : []
        differences.each_key { |field| conflicts[record.id].add(field) }
      end
    end

    conflicts
  end

  private

  def compare(record, other)
    difference = record.attributes.to_a - other.attributes.to_a
    Hash[*difference.flatten]
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

    find(record, maybe_matches, fields)
  end
end
