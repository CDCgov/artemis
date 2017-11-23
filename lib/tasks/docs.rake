namespace :docs do
  desc 'Generates required documents from Markdown'
  task generate: :environment do
    [
      'catalog.md',
      'Manual - FHIRfighters.md',
      'Special Instructions - FHIRfighters.md'
    ].each do |source|
      result = system "npm run markdown-pdf '#{source}'" # NOTE: yarn has a bug
      raise StandardError, "Could not convert #{source}" unless result
    end
  end
end
