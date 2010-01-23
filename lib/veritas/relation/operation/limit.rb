module Veritas
  class Relation
    module Operation
      class Limit < Relation
        include Unary

        def self.new(relation, limit)
          if relation.directions.empty?
            raise OrderedRelationRequiredError, 'can only limit an ordered relation'
          end

          super
        end

        def initialize(relation, limit)
          @limit = limit.to_int
          super(relation)
        end

        def each
          relation.each_with_index do |tuple, index|
            break if @limit == index
            yield tuple
          end
          self
        end

        def optimize
          relation = optimize_relation

          case relation
            when Limit then optimize_limit(relation)
            else
              super
          end
        end

        def to_i
          @limit
        end

      private

        def new_optimized_operation
          self.class.new(optimize_relation, to_i)
        end

        def optimize_limit(other)
          limit, other_limit = to_i, other.to_i

          if limit == other_limit
            other
          else
            other.class.new(other.relation, [ limit, other_limit ].min)
          end
        end

      end # class Limit
    end # module Operation
  end # class Relation
end # module Veritas
