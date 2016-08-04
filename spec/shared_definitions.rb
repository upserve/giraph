shared_context 'sample graphql structure' do
  class MockResolver; end

  let(:schema) do
    GraphQL::Schema.new(
      query: query_root,
      # mutation: mutation_root
    )
  end

  let(:query_root) do
    GraphQL::ObjectType.define do
      name 'Query'

      field :test do
        type types.Int
        argument :foo, types.String
        resolve MockResolver
      end
    end
  end

  let(:query_context) do
    {
      bar: [1, 2]
    }
  end

  let(:query_string) do
    'query Test($baz: String) { test(foo: $baz) }'
  end

  let(:query_variables) do
    { 'baz' => 'foo value' }
  end

  let(:giraph_response) do
    Giraph::Remote::Response[
      test: 84
    ]
  end
end
