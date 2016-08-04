module Giraph
  # Proc-like class to allow declerative links to external
  # resolution handlers (so the "definition" gem can stay pure resolution-wise)
  class Resolver
    class UnknownOperation < StandardError; end

    def initialize(resolver_method)
      @resolver_method = resolver_method
    end

    # Resolves the field by calling the previously given method
    # on the registered Resolver object for the current operation
    # type (currently query or mutation)
    def call(obj, args, ctx)
      # Find out operation type (query, mutation, etc.)
      op_type = ctx.query.selected_operation.operation_type.to_sym

      # Ensure there is a registered resolver for it
      unless (resolver = ctx[:__giraph_resolver__][op_type])
        raise UnknownOperation, "No resolver found for '#{op_type}' op type"
      end

      # Call the requested method on resolver
      resolver.send(@resolver_method, obj, args, ctx)
    end
  end
end
