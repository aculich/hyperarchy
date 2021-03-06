module Monarch
  module Model
    module Tuples
      class ConcreteField < Field
        delegate :name, :to => :column

        def initialize(record, column)
          super(record, column)
          @update_node = Util::SubscriptionNode.new
        end

        def value=(value)
          raise "This is a snapshot field. It is read only." if snapshot?

          new_value = column.convert_value_for_storage(value)
          if @value != new_value
            @value = new_value
            mark_dirty
            update_node.publish(new_value)
          end
        end

        def on_update(&block)
          update_node.subscribe(&block)
        end

        delegate :sql_expression, :to => :value

        def signal(&block)
          Signal.new(self, &block)
        end

        def sql_expression(state)
          value.sql_expression(state)
        end

        protected
        attr_reader :update_node
      end
    end
  end
end