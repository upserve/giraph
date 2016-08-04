shared_context 'sample graphql structure' do
  class MockResolver; end

  let(:schema) do
    Giraph::Schema.new(
      query: query_root,
      query_resolver: query_resolver
    )
  end

  let(:query_root) do
    TheType = GraphQL::ObjectType.define do
      name 'TheType'

      field :res, types.Int
    end

    GraphQL::ObjectType.define do
      name 'Query'

      field :test do
        type TheType
        argument :foo, types.String
        resolve MockResolver
      end

      field :proxy do
        type TheType
        argument :foo, types.String
        resolve Giraph::Resolver.new(:resolver_method)
      end
    end
  end

  let(:query_resolver) do
    double(:query_resolver)
  end

  let(:query_context) do
    {
      bar: [1, 2]
    }
  end

  let(:query_string) do
    'query Test($baz: String) { test(foo: $baz) { res } }'
  end

  let(:query_variables) do
    {
      'baz' => 'foo value'
    }
  end
end
