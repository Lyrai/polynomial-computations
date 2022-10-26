require_relative 'lexer'
require_relative 'parser'
require_relative 'simplifier'
require_relative 'constant_folder'
require_relative 'power_expander'
require_relative 'polynomial_composer'
include PolynomialComputations

puts "Enter expression: "
expr = gets.chomp
l = Lexer.new expr
p = Parser.new l.tokens
tree = p.parse
tree.print
puts "--------------------------"
tree.print
f = ConstantFolder.new tree
tree = f.fold
puts "--------------------------"
tree.print
e = PowerExpander.new tree
tree = e.expand
puts "--------------------------"
tree.print
s = Simplifier.new tree
tree = s.simplify
puts "--------------------------"
tree.print

c = PolynomialComposer.new(tree)
poly = c.compose
puts "--------------------------"
puts "Polynomial: " +  poly.to_s

puts "Diff: " + poly.derivative("x").to_s