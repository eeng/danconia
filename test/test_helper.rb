require 'test/unit'
require 'active_record'
require "#{File.dirname(__FILE__)}/../lib/acts_as_money"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class Test::Unit::TestCase #:nodoc:
  def setup
    ActiveRecord::Schema.define(:version => 1) do
      create_table :products do |t|
        t.column :price, :decimal, :precision => 12, :scale => 2
        t.column :tax, :decimal, :precision => 12, :scale => 2
        t.column :discount, :decimal, :precision => 12, :scale => 3
      end
    end
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
end