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
            orders += " LOWER(\"#{ self.name.downcase.pluralize }\".\"#{ column.to_s.downcase }\") #{ order.to_s.upcase }"
          else
            orders += " \"#{ self.name.downcase.pluralize }\".\"#{ column.to_s.downcase }\" #{ order.to_s.upcase }"
          end
        end
      end
      orders.empty? ? self.where(nil) : self.reorder(Arel.sql(orders))
    end
  end
end
