module Giraph
  module Remote
    # Dummy Hash-wrapper to enable precise `instance_of?` checks
    # Allows us to differentiate JSON responses that are
    # coming from remote GraphQL interface vs regular Hash objects
    class Response < Hash
    end
  end
end
