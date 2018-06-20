module ActsAsMoney
  class Config
    @default_currency = 'USD'
    @available_currencies = []

    class << self
      attr_accessor :default_currency, :available_currencies

      def to_h
        instance_variables.inject({}) { |c, var| c[var.to_s[1..-1].to_sym] = instance_variable_get(var); c }
      end
    end
  end
end
