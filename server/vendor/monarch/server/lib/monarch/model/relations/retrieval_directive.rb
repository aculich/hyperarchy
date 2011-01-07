module Monarch
  module Model
    module Relations
      class RetrievalDirective < UnaryOperator
        attr_reader :count, :concrete_columns, :concrete_columns_by_name, :concrete_columns_by_underlying_expression

        class << self
          def from_wire_representation(representation, repository)
            operand = Relation.from_wire_representation(representation["operand"], repository)
            new(operand, representation["count"])
          end
        end

        def initialize(operand, count, &block)
          super(&block)
          @operand = operand
          @count = count
          @concrete_columns = operand.concrete_columns.map {|column| column.derive(self)}
          @concrete_columns_by_name = {}
          @concrete_columns_by_underlying_expression = {}
          concrete_columns.each do |derived_column|
            concrete_columns_by_name[derived_column.name] = derived_column if derived_column.name
            concrete_columns_by_underlying_expression[derived_column.expression] = derived_column
          end
        end

        def columns
          concrete_columns
        end

        def column(expression_or_name_or_index)
          case expression_or_name_or_index
          when String, Symbol
            concrete_columns_by_name[expression_or_name_or_index]
          when Expressions::Expression
            if (concrete_columns.include?(expression_or_name_or_index))
              expression_or_name_or_index
            else
              concrete_columns_by_underlying_expression[expression_or_name_or_index]
            end
          when Expressions::ConcreteColumn, Expressions::AggregationFunction
            expression_or_name_or_index
          when Integer
            concrete_columns[expression_or_name_or_index]
          end
        end

        def ==(other)
          return false unless other.instance_of?(self.class)
          operand == other.operand && count == other.count
        end

        def surface_tables
          [self]
        end

        def external_sql_select_list(state, external_relation)
          state[self][:external_sql_select_list] ||= [Sql::Asterisk.new(external_sql_table_ref(state))]
        end

        def has_derived_external_table_ref?
          true
        end

        # always produces a derived table. if it is layered on top of a relation that also requires a derived table, only one
        # will be produced because we delegate all internal_ methods to the operand (thereby avoiding ever calling its external_ methods,
        # which might produce another derived table) we always produce a derived table here, so it will be okay.
        def external_sql_table_ref(state)
          state[self][:external_sql_table_ref] ||= Sql::DerivedTable.new(sql_query_specification(state), state.next_derived_table_name, self)
        end

        def external_sql_where_predicates(state)
          []
        end

        def external_sql_grouping_column_refs(state)
          []
        end

        def external_sql_sort_specifications(state)
          []
        end

        protected

        # offsets and limits mimic their operand in every respect except the sql offset. even the internal sql select list, which
        # will be in terms # of the columns of the operand instead of the derived columns of the offset is ok, because
        # the offset doesn't rename anything. all the offset's derived columns refer back to the operands columns by name
        delegate :internal_sql_select_list, :internal_sql_table_ref, :internal_sql_where_predicates, :internal_sql_grouping_column_refs,
                 :internal_sql_sort_specifications, :internal_sql_offset, :internal_sql_limit, 
                 :to => :operand
      end
    end
  end
end