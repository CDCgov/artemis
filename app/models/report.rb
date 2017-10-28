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
    (data['conflicts'] || []).to_a.map do |id, fields|
      OpenStruct.new(
        id: id,
        nbs: NBS::NewbornRecord.find_or_match(id, OVRS::NewbornRecord),
        ovrs: OVRS::NewbornRecord.find_or_match(id, NBS::NewbornRecord),
        fields: fields || []
      )
    end
  end
end
