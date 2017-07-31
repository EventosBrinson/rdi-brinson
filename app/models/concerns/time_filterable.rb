module TimeFilterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter_by_time(params = {})
      results = self.where(nil)
      query = ""
      params[:beginning_time] = DateTime.parse(params[:beginning_time]) if params[:beginning_time].kind_of?(String)
      params[:end_time] = DateTime.parse(params[:end_time]) if params[:end_time].kind_of?(String)
      params[:columns].each do |column|
        if self.has_attribute? column.to_sym
          query += ' OR ' unless query.empty?
          query += "(#{ self.name.downcase.pluralize }.#{ column.to_s.downcase } BETWEEN :beginning_time AND :end_time)"
        end
      end
      results.where(query, beginning_time: params[:beginning_time], end_time: params[:end_time])
    end
  end
end
