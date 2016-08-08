module Giraph
  module Remote
    # Dummy Hash-wrapper to enable precise `instance_of?` checks
    # Allows us to differentiate JSON responses that are
    # coming from remote GraphQL interface vs regular Hash objects
    # including all nested hashes within a response.
    class Response < Hash
      # Factory method to encapsulate special parsing logic
      def self.from_json(raw_json)
        JSON.parse(raw_json, symbolize_names: true, object_class: self)
      end
    end
  end
end
