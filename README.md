
# PincodeFinder

**PincodeFinder** is a simple Ruby gem that allows you to find details about Indian pincodes, such as the pincode, district, and state, based on the pincode provided.

## Features

- **Pincode Lookup**: Retrieve information such as district and state using a valid Indian pincode.
- **Efficient Data Storage**: Compressed data format to minimize the memory footprint.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pincode_finder'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install pincode_finder
```

## Usage

After installing the gem, you can use it in your Ruby code as follows:

```ruby
require 'pincode_finder'

# Example usage:
result = PincodeFinder.find('110001')
puts result[:district]  # Output: 'Central Delhi'
puts result[:state]     # Output: 'Delhi'
```

### Methods

- **`PincodeFinder.find(pincode)`**: Finds and returns details about the provided pincode.
  - **Arguments**: 
    - `pincode` (String): The pincode you want to look up.
  - **Returns**: 
    - A hash with keys `:pincode`, `:district`, and `:state`.

## Development

To set up the development environment:

1. Clone the repository:
   ```bash
   git clone git@github.com:aadhi-flaerhomes/pincode_finder.git
   cd pincode_finder
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Run tests:
   ```bash
   rake test
   ```

### Console

To experiment with the code in a console, run:

```bash
bin/console
```

This will load an interactive Ruby console with the gem's code loaded, allowing you to test the gem's functionality directly.

## Data Storage Format

The pincode data is stored in a compressed JSON format. This allows the gem to have a smaller footprint while still providing fast lookup times. If you need to update the data:

1. Modify the source data file in CSV format.
2. Use the provided script to compress and convert the data to a `.gz` file.
3. Replace the existing `pincode_data.json.gz` file in the `data/` directory.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aadhi-flaerhomes/pincode_finder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/aadhi-flaerhomes/pincode_finder/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PincodeFinder project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/aadhi-flaerhomes/pincode_finder/blob/master/CODE_OF_CONDUCT.md).
```

### Notes:
- **Installation:** The commands `bundle install` and `gem install pincode_finder` ensure users can install the gem.
- **Usage:** Provided examples demonstrate how to use the gem.
- **Development:** Instructions for setting up the development environment and running tests.
- **Data Storage Format:** Explanation of how the data is stored and how to update it if needed.
- **Contributing:** Guidelines for contributing to the project.

Feel free to modify this template as needed to fit the specifics of your gem.