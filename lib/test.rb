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
expr1 = gets.chomp
poly1 = Polynomial.from_s(expr1)
puts "Polynomial1: " + poly.to_s + " Polynomial2: " + poly1.to_s
d = poly.+(poly1)
puts "Polynomial: " + d.to_s

puts "Polynomial: " + poly.integrate('x').to_s
