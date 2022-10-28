# PolynomialComputations

Gem that handles simple mathematical operations, such as: 
--Finding roots
--Derivative calculation
--Calculation of polynomials of degree 2 or less
--Operations + - * for polynomials

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add polynomial_computations

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install polynomial_computations

## Usage


    Use 'Polynomial.calculate(variables)' to calculate polynomial by array of variables
    Use 'Polynomial.derivative(base)' to differentiate equation by varibable base
    Use 'Polynomial.roots' to find the roots of a polynomial
    Use 'Polynomial.from_s' to get polynomial from string
    Use 'Polynomial.+(Other_Polynomial)' or 'Polynomial + Other_Polynomial' for polynomial addition
    Use 'Polynomial.-(Other_Polynomial)' or 'Polynomial - Other_Polynomial' for polynomial substruction
    Use 'Polynomial.*(Other_Polynomial)' or 'Polynomial * Other_Polynomial' for polynomial multiplication
    Use 'Polynomial.to_s' to convert polynimal to string
    
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/polynomial_computations.
