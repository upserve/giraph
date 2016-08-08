module Giraph
  module Remote
    # Field resolver to plug a remote GraphQL query root into a local type
    class Query
      def self.bind(endpoint, &block)
        new(
          endpoint,
          Remote::Connector.new(endpoint),
          &block
        )
      end

      def initialize(endpoint, connector, &block)
        @endpoint = endpoint
        @evaluator = block || method(:default_evaluator)
        @connector = connector
      end

      # Reconstructs a valid GraphQL root-query from the current
      # field in question, including all variables and params,
      # hands over to connector to execute remotely.
      def call(obj, args, ctx)
        # Given an evaluator block, continue if only it evaluates to non-nil!
        return unless (remote_root = @evaluator.call(obj, args, ctx))

        subquery = Subquery.new(ctx)

        # Continue with remote query execution
        connector.resolve(
          ctx,
          query_string(subquery),
          query_variables(subquery, remote_root)
        )
      end

      private

      def query_type
        'query'
      end

      def query_string(subquery)
        # Full GraphQL query for remote
        "#{query_type} #{subquery.subquery_string}"
      end

      def query_variables(subquery, remote_root)
        # Variable hash to send along
        subquery.variable_string do |dict|
          dict.merge(__giraph_root__: remote_root)
        end
      end

      def default_evaluator(*args)
        {}
      end

      attr_reader :endpoint, :connector
    end
  end
end
