module Orderable
  extend ActiveSupport::Concern

  module ClassMethods
    def ordered(columns = {})
      results = self.where(nil)
      orders = ''
      columns.each do |column, order|
        if self.column_names.include?(column.to_s.downcase) and ['asc', 'desc'].include?(order.to_s.downcase)
          orders += ',' unless orders.empty?
          orders += " LOWER(\"#{ self.name.downcase.pluralize }\".\"#{column.to_s.downcase}\") #{order.to_s.downcase}"
        end
      end
      results.order(orders)
    end
  end
end
