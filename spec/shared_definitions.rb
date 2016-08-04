shared_context 'sample graphql structure' do
  class MockResolver; end

  let(:schema) do
    Giraph::Schema.new(
      query: query_root,
      query_resolver: query_resolver,
      mutation: mutation_root,
      mutation_resolver: mutation_resolver
    )
  end

  let(:query_root) do
    the_type = GraphQL::ObjectType.define do
      name 'the_type'

      field :res, types.Int
    end

    GraphQL::ObjectType.define do
      name 'Query'

      field :test do
        type the_type
        argument :foo, types.String
        resolve MockResolver
      end

      field :proxy do
        type the_type
        argument :foo, types.String
        resolve Giraph::Resolver.new(:resolver_method)
      end
    end
  end

  let(:mutation_root) do
    input_type = GraphQL::InputObjectType.define do
      name 'input_type'

      input_field :foo, types.String
      input_field :bar, types.Int
    end

    mutation_type = GraphQL::ObjectType.define do
      name 'mutation_type'

      field :update do
        type types.Int
        argument :input, !input_type
        resolve Giraph::Resolver.new(:update)
      end
    end

    GraphQL::ObjectType.define do
      name 'Mutation'

      field :test do
        type mutation_type
        argument :foo, types.String
        resolve MockResolver
      end

      field :proxy do
        type mutation_type
        argument :foo, types.String
        resolve Giraph::Resolver.new(:resolver_method)
      end
    end
  end

  let(:query_resolver) do
    double(:query_resolver)
  end

  let(:mutation_resolver) do
    double(:mutation_resolver)
  end

  let(:query_context) do
    {
      bar: [1, 2]
    }
  end

  let(:query_string) do
    %(
      query Test($baz: String) {
        test(foo: $baz) {
          res
        }
      }
    )
  end

  let(:mutation_string) do
    %(
      mutation Test($baz: String) {
        test(foo: $baz) {
          update(input: {foo: $baz, bar: 21})
        }
      }
    )
  end

  let(:query_variables) do
    {
      'baz' => 'foo value'
    }
  end
end
