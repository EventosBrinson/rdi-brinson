module Filterable
  extend ActiveSupport::Concern

  PERMITED_MESSAGES = [:filter, :ordered, :paginated]

  module ClassMethods
    def filter(filtering_params, permited = nil)
      results = self.where(nil)
      filtering_params.each do |method, params|
        if method.present? and self.respond_to?(method.to_sym) and (permited || PERMITED_MESSAGES).include?(method)
          results = results.public_send(method, params)
        end
      end
      results
    end
  end
end
