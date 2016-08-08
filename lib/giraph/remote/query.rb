module Giraph
  module Remote
    # Field resolver to plug a remote GraphQL query root into a local type
    class Query
      def self.bind(endpoint, &block)
        new(
          endpoint,
          Remote::Connector.new(endpoint, mutation: false),
          &block
        )
      end

      def initialize(endpoint, connector, &block)
        @endpoint = endpoint
        @evaluator = block || method(:default_evaluator)
        @connector = connector
      end

      def call(obj, args, ctx)
        # Given an evaluator block, continue if only it evaluates to non-nil!
        return unless (remote_root = @evaluator.call(obj, args, ctx))

        # Continue with remote query execution
        connector.resolve(ctx, remote_root: remote_root.to_h)
      end

      private

      def default_evaluator(*args)
        {}
      end

      attr_reader :endpoint, :mutation, :connector
    end
  end
end
