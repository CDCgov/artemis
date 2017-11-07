module ReportsHelper
  def format_conflict(conflict, fallback = '[blank]')
    conflict.fields.reject { |x| x == 'id' }.map do |field|
      OpenStruct.new(
        field: field.titlecase,
        nbs:   conflict.nbs.send(field) || fallback,
        ovrs:  conflict.ovrs.send(field) || fallback
      )
    end
  end
end
