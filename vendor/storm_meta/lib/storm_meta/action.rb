module StormMeta
  module Action
    def actions
      @actions ||= {}
    end

    def action(name, &block)
      definition = ActionDefinition.new(name)
      definition.instance_eval(&block) if block_given?
      actions[name.to_sym] = definition

      define_singleton_method(name) do |ctx = {}|
        actions[name.to_sym].call(ctx)
      end
    end

    class ActionDefinition
      attr_reader :name, :params, :steps

      def initialize(name)
        @name   = name
        @params = []
        @steps  = []
      end

      def param(name, type = :any)
        @params << [name, type]
      end

      def step(name = nil, &block)
        @steps << (block || name.to_sym)
      end

      def call(ctx)
        @steps.each do |s|
          case s
          when Symbol
            if ctx.respond_to?(s)
              ctx.public_send(s)
            elsif ctx.is_a?(Hash) && ctx.key?(s)
              ctx[s]
            end
          else
            s.call(ctx)
          end
        end
      end
    end
  end
end