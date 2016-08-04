module Giraph
  module Remote
    # Field resolver to plug a remote GraphQL mutation root into a local type
    class Mutation < Query
      def initialize(*args)
        super
        # Override the mutation flag, rest is the same
        @mutation = true
      end
    end
  end
end
