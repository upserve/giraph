module Giraph
  # Wrapped methods on GraphQL::Field class
  module Extensions
    module Field
      # Wrap the 'resolve' method on Field so that we can
      # intercept the registered resolution Proc and resolve
      # on already-resolved values from the JSON returned
      # to the sub-query through the remote endpoint
      def resolve(object, arguments, context)
        # Giraph always parses a remote response with a special Hash
        # class called 'Giraph::Remote::Response', which is a no-op sub-class
        # of Hash. This way we can easily recognize this special
        # "resolve on already resolved response" case while still
        # allowing regular Hash to be resolved normally.
        if object.instance_of? Giraph::Remote::Response
          # If the field was aliased, response will be keyed by the alias
          field = context.ast_node.alias || context.ast_node.name
          object[field.to_sym]
        else
          # Not Giraph, let it through...
          super
        end
      end
    end
  end
end

# Monkey-patch GraphQL Field class to wrap the default 'resolve'
module GraphQL
  class Field
    prepend Giraph::Extensions::Field
  end
end
