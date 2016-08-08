module Giraph
  module Remote
    class InvalidResponse < StandardError; end

    # sends the reconstructed subquery request and parses the response.
    class Connector
      def initialize(endpoint)
        @endpoint = endpoint
      end

      # The resolver method for the connection field.
      def resolve(context, query_string, query_variables)
        # Remote can return data, error or totally freak out,
        # we handle all here, and note anything of relevance
        result = run_query(query_string, query_variables)
        return_data_or_raise(result) do |exception|
          # Tack on details for host's version of the query
          exception.ast_node = context.ast_node
        end
      end

      private

      def run_query(query, variable)
        Net::HTTP.post_form(URI(@endpoint), query: query, variables: variable)
      end

      def return_data_or_raise(response, &block)
        result = Remote::Response.from_json(response.body)

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
    end
  end
end
