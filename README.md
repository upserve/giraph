# Giraph

_(Pronounced with a G as in GIF)_

Ever wanted to have multiple GraphQL endpoints presented under one? 

Ever felt like interactions between micro-services are not DRY enough?

If so, you'll feel right at home with Giraph. 

Giraph allows you to plug-in a remote GraphQL endpoint under another one as a regular field.
You can now plug a remote GraphQL endpoint in as a field anywhere within your type hierarchy, 
allow clients to send a single unified query, have the remote servers resolve their respective
sub-queries and return a valid response that all seamlessly comes together.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'giraph'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install giraph

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/upserve/giraph.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

