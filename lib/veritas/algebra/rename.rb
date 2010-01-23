module Veritas
  module Algebra
    class Rename < Relation
      include Relation::Operation::Unary

      attr_reader :aliases

      def initialize(relation, aliases)
        @aliases = aliases
        super(relation)
      end

      def header
        @header ||= relation.header.rename(@aliases)
      end

      def each(&block)
        relation.each do |tuple|
          yield Tuple.new(header, tuple.to_ary)
        end
        self
      end

      def optimize
        relation = optimize_relation

        case relation
          when Relation::Empty then new_empty_relation
          when self.class      then optimize_rename(relation)
          else
            super
        end
      end

    private

      def new_optimized_operation
        self.class.new(optimize_relation, aliases)
      end

      def optimize_rename(other)
        aliases  = optimize_aliases(other)
        relation = other.relation

        if aliases.empty?
          relation
        else
          self.class.new(relation, aliases)
        end
      end

      # TODO: create Rename::Aliases object, and move this to a #union method
      def optimize_aliases(other)
        aliases  = other.aliases.dup
        inverted = aliases.invert

        self.aliases.each do |old_attribute, new_attribute|
          old_attribute = inverted.fetch(old_attribute, old_attribute)

          if old_attribute == new_attribute
            aliases.delete(new_attribute)
          else
            aliases[old_attribute] = new_attribute
          end
        end

        aliases
      end

    end # class Rename
  end # module Algebra
end # module Veritas
