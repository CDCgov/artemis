module ReportsHelper
  def render_newborn_record(record, fields = [])
    return '[none found]' if record.blank?
    record.attributes.except(:id).map do |attribute, value|
      (value || '<em>[blank]</em>').to_s if fields.include? attribute.to_s
    end.compact.join("\n")
  end
end
