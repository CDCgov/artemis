module ReportsHelper
  def format_conflict(conflict, fallback = '[blank]')
    conflict.fields.reject { |x| x == 'id' }.map do |field|
      OpenStruct.new(
        field: field.titlecase,
        nbs:   conflict.nbs[field] || fallback,
        ovrs:  conflict.ovrs[field] || fallback
      )
    end
  end
end
