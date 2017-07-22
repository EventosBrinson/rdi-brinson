module Orderable
  extend ActiveSupport::Concern

  module ClassMethods
    def ordered(columns = {})
      orders = ''
      columns.each do |column, order|
        if self.column_names.include?(column.to_s.downcase) and ['asc', 'desc'].include?(order.to_s.downcase)
          orders += ',' unless orders.empty?
          case self.column_for_attribute(column.to_s.downcase).type
          when :string, :text
            orders += " LOWER(\"#{ table_name }\".\"#{ column.to_s.downcase }\") #{ order.to_s.upcase }"
          else
            orders += " \"#{ table_name }\".\"#{ column.to_s.downcase }\" #{ order.to_s.upcase }"
          end
        end
      end
      orders.empty? ? self.where(nil) : self.reorder(orders)
    end

    private

    def table_name
      self.name.downcase.pluralize
    end
  end
end
