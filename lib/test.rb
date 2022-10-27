require_relative 'lexer'
require_relative 'parser'
require_relative 'simplifier'
require_relative 'constant_folder'
require_relative 'power_expander'
require_relative 'polynomial_composer'
include PolynomialComputations

puts "Enter expression: "
expr = gets.chomp
poly = Polynomial.from_s(expr)
puts "Polynomial: " + poly.to_s

puts "Diff: " + poly.derivative("x").to_s
