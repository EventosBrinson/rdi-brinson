module Paginatable
  extend ActiveSupport::Concern

  module ClassMethods
    def paginated(range = {})
      result = self.where(nil)
      result = result.offset(range[:offset].to_i) if range[:offset]
      result = result.limit(range[:limit].to_i) if range[:limit]
    end
  end
end
