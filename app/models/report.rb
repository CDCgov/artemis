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
end
