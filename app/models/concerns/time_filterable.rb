module TimeFilterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter_by_time(beginning_time, end_time, *columns)
      results = self.where(nil)
      query = ""
      columns.each do |column|
        if self.has_attribute? column.to_sym
          query += ' OR ' unless query.empty?
          query += "(#{ self.name.downcase.pluralize }.#{ column.to_s.downcase } BETWEEN :beginning_time AND :end_time)"
        end
      end
      results.where(query, beginning_time: beginning_time, end_time: end_time)
    end
  end
end
