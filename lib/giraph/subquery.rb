module Giraph
  class Subquery
    attr_reader :query, :query_string

    def initialize(context)
      @context = context

      @query = context.query
      @query_string = context.ast_node.to_query_string
    end

    def subquery_string
      "GiraphQuery #{query_variables} #{query_selections}"
    end

    def variable_string
      dict = variable_assignments
      dict = yield dict if block_given?

      dict.to_json
    end

    private

    def variable_assignments
      # This re-encodes and passes on all the variable values
      # paseed to the original query endpoint
      query.instance_variable_get('@provided_variables')
    end

    def query_selections
      # We get the following from node's sub-query:
      #   nodeName { field1 { field12 } field2(a: $a) field3 }
      # we want:
      #   { field1 { field12 } field2(a: $a) field3 }
      # as the name of node is local information to parent host
      # and is no use to the remote host.
      query_string.sub(/^[^{]+/, '')
    end

    def query_variables
      # Recreates the declared query parameters to be passed on
      # to the remote host.
      declerations = query
                     .selected_operation
                     .variables
                     .select(&method(:variable_used?))
                     .map(&method(:variable_decleration))

      "(#{declerations.join(', ')})" unless declerations.empty?
    end

    def variable_used?(variable)
      query_string[/\$#{Regexp.quote(variable.name)}\W/]
    end

    def variable_decleration(variable)
      "$#{variable.name}: #{variable_type(variable)}"
    end

    def variable_type(variable)
      if variable.type.is_a?(GraphQL::Language::Nodes::NonNullType)
        variable.type.of_type.name + '!'
      else
        variable.type.name
      end
    end
  end
end
