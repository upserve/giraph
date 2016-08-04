module Giraph
  module Remote
    # Field resolver to plug a remote GraphQL query root into a local type
    class Query
      def initialize(endpoint, &block)
        @endpoint = endpoint
        @evaluator = block || method(:default_evaluator)
        # Default is a query, can be overriden by sub-classes
        @mutation = false
      end

      def call(obj, args, ctx)
        # Given an evaluator block, continue if only it evaluates to non-nil!
        return unless (remote_root = @evaluator.call(obj, args, ctx))

        # Continue with remote query execution
        connector.resolve(ctx, remote_root: remote_root.to_h)
      end

      private

      def connector
        @connector ||= Remote::Connector.new(endpoint, mutation: mutation)
      end

      def default_evaluator(*args)
        {}
      end

      attr_reader :endpoint, :mutation
    end
  end
end
