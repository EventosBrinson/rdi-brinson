module Filterable
  extend ActiveSupport::Concern

  PERMITED_MESSAGES = [:ordered, :paginated, :search]

  module ClassMethods
    def filter(filtering_params, permited = nil)
      results = self.where(nil)
      filtering_params.each do |method, params|
        if method.present? and self.respond_to?(method.to_sym) and (permited || PERMITED_MESSAGES).include?(method.to_sym)
          results = results.public_send(method, params)
        end
      end
      results
    end
  end
end
