module Giraph
  module Remote
    # Field resolver to plug a remote GraphQL mutation root into a local type
    class Mutation < Query
      def self.bind(endpoint, &block)
        new(
          endpoint,
          Remote::Connector.new(endpoint, mutation: true),
          &block
        )
      end
    end
  end
end
