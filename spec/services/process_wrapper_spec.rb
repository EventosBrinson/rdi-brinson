require 'rails_helper'

describe ProcessWrapper do
  let(:dummy_service) do 
    Class.new do
      extend ProcessWrapper
      
      def initialize(param_a, param_b)
      end
      
      define_method(:process) { "process_executed" } 
    end
  end

  describe '.for' do
    it 'returns the result of the instance method process' do
      result = dummy_service.for('trivial_value_a', 'trivial_value_b')

      expect(result).to eq "process_executed"
    end
  end
end
