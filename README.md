<img height='196px' src='https://github.com/upserve/giraph/blob/master/github-header.png?raw=true'>

> _(Pronounced "Giraph" as in GIF)_

Ever wanted to have multiple GraphQL endpoints presented under one? 

Ever felt like interactions between your micro-services are not DRY enough?

Ever found yourself thinking "there has to be a better way!"

If so, welcome to Giraph!

Giraph allows you to plug a remote GraphQL endpoint under your GraphQL enddpoint as a regular field.
You can now execute queries and mutations on the remote as if it was a regular field anywhere within your type hierarchy, 
allowing clients to have a single point of interaction. Have the remote servers handle their respective
sub-queries and just plug the response back in to your result seamlessly.

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

TODO: Provide usage examples (remote hierarchy, local hierarchy, definition gem etc.)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/upserve/giraph.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

