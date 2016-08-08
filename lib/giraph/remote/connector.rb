module Giraph
  module Remote
    class InvalidResponse < StandardError; end

    # Reconstructs a valid GraphQL root-query from the current
    # field in question, including all variables and params,
    # sends the query request and parses the response.
    class Connector
      def initialize(endpoint, mutation: false)
        @endpoint = endpoint
        @mutation = mutation
      end

      # The resolver method for the connection field.
      def resolve(context, remote_root: {})
        subquery = Subquery.new(context)

        # Full GraphQL query for remote
        query = "#{query_type} #{subquery.subquery_string}"

        # Variable hash to send along
        variables = subquery.variable_string do |dict|
          dict.merge(__giraph_root__: remote_root)
        end

        # Remote can return data, error or totally freak out,
        # we handle all here, and note anything of relevance
        return_data_or_raise(run_query(query, variables)) do |exception|
          # Tack on details for host's version of the query
          exception.ast_node = context.ast_node
        end
      end

      private

      def query_type
        @mutation ? 'mutation' : 'query'
      end

      def run_query(query, variable)
        Net::HTTP.post_form(URI(@endpoint), query: query, variables: variable)
      end

      def return_data_or_raise(response, &block)
        result = to_giraph_json(response.body)

        # Remote returned a valid result set, pass it through
        return result[:data] if result[:data]

        # Remote returned a GraphQL error, raise it as such
        raise remote_execution_error(result[:errors], block)
      rescue JSON::ParserError
        # Remote server returned an invalid result (non-JSON response)
        # meaning something went wrong. Raise an error that reflects this.
        raise(
          InvalidResponse,
          "Remote endpoint returned: '#{response.code} #{response.msg}'"
        )
      end

      def remote_execution_error(errors, block)
        GraphQL::ExecutionError.new(errors).tap do |ex|
          # Allow exception to be modified if needed
          block.call(ex) if block
        end
      end

      # We specifically parse JSON using Giraph::Remote::Response
      # in place of regular Hash so that downstreams can realize
      # that this is a Giraph-sourced remote response.
      def to_giraph_json(raw_json)
        JSON.parse(
          raw_json,
          symbolize_names: true,
          object_class: Remote::Response
        )
      end
    end
  end
end
