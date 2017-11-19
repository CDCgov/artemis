# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  requestor  :string
#  type       :string
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# A generic report to hold data, currently only used for Discrepancy Reports
class Report < ApplicationRecord
  self.inheritance_column = :_type_disabled

  def conflicts
    (data['conflicts'] || []).map do |conflict|
      conflict = conflict.with_indifferent_access
      OpenStruct.new(
        id: conflict[:id],
        nbs: OpenStruct.new(conflict[:nbs]),
        ovrs: OpenStruct.new(conflict[:ovrs]),
        fields: conflict[:fields]
      )
    end
  end

  def nbs
    @nbs ||= casted_records NBS::NewbornRecord
  end

  def ovrs
    @ovrs ||= casted_records OVRS::NewbornRecord
  end

  private

  def casted_records(model, key = nil)
    key ||= model.try(:prefix).try(:downcase)
    data.fetch(key, []).map do |record|
      model.new record.fetch('attributes', {})
    end
  end
end
