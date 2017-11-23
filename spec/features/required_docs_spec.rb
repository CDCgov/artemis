require 'rails_helper'

RSpec.describe 'Required documents', type: :feature do
  let(:glob) { Dir.glob('**/*') }

  [
    'Deliverable 1 Presentation.pdf',
    'Deliverable 4 Presentation.pdf',
    'catalog.pdf',
    'docker-compose.yml',
    'Final Gantt Chart - FHIRfighters.pdf',
    'Manual - FHIRfighters.pdf',
    'Special Instructions - FHIRfighters.pdf',
    'research'
  ].each do |file|
    specify "#{file} is present" do
      expect(glob.include?(file)).to be true
    end
  end
end
