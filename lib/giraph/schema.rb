module Giraph
  # GraphQL::Schema wrapper allowing decleration of
  # resolver objects per op type (query or mutation)
  class Schema < DelegateClass(GraphQL::Schema)
    # Extract special arguments for resolver objects,
    # let the rest pass-through
    def initialize(**args)
      @query_resolver = args.delete(:query_resolver)
      @mutation_resolver = args.delete(:mutation_resolver)
      super(GraphQL::Schema.new(**args))
    end

    # Defer the execution only after setting up
    # context and root_value with resolvers and remote arguments
    def execute(query, **args)
      args = args
             .merge(with_giraph_root(args))
             .merge(with_giraph_resolvers(args))

      super(query, **args)
    end

    private

    def with_giraph_root(args)
      # Extract & remove the special __giraph_root__ key
      # from variables passed in, if any
      vars = args[:variables] || {}
      root = vars.delete('__giraph_root__') || {}

      # Set given pseudo-root as root_value for the execution
      { root_value: root }
    end

    def with_giraph_resolvers(args)
      # Pass on resolver objects in context
      # which will then be used by Giraph resolvers
      # to direct per-field resolution
      context = args[:context] || {}
      context[:__giraph_resolver__] = {
        query: @query_resolver,
        mutation: @mutation_resolver
      }

      { context: context }
    end
  end
end
