module ReportsHelper
  def render_newborn_record(record, emphasized = [])
    return '[none found]' if record.blank?
    record.attributes.except(:state_file_number, :id).map do |attribute, value|
      line = "#{attribute}:\t#{value || '[blank]'}"
      emphasized.include?(attribute.to_s) ? "<strong>#{line}</strong>" : line
    end.sort.join("\n")
  end
end
