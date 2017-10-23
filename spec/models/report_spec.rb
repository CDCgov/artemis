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

RSpec.describe Report, type: :model do
end
