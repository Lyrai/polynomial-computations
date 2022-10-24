# frozen_string_literal: true
require_relative 'lexer'
require_relative 'parser'
require_relative "polynomial_computations/version"

module PolynomialComputations
  class Error < StandardError; end

  class Term

    def matches_variables?(term)
      if factors.length != term.factors.length
        return false
      end
      for i in 0..term.factors.size do
        unless term.factors[i].power_base == factors[i].power_base and term.factors[i].power_exp == factors[i].power_exp
          return false
        end
        true
      end
    end

    def term_number()
      return
    end

  end

  class Factor

  end

  class Polynomial
    def initialize(arr)
      @terms = arr
    end

    def self.from_string(str)
      lexer = Lexer.new(str)
      parser = Parser.new(lexer.tokens)

    end

    def calculate_powers(variables, factor)
      if factor.power_exp == 0
        return factor.number
      end
      factor.number * calculate_powers(variables, factor.power_base) ** calculate_powers(variables, factor.power_exp)
    end

    def calculate(variables)
      res = 0
      @terms.each do |term|
        help_res = 1
        term.each do |factor|
          help_res *= calculate_powers(variables, factor)
        end
        res += help_res
      end
      res
    end

    def find_term(other_term)
      @terms.each do |term|
        if term.matches_variables?(other_term)
          return term
        end
      end
      nil
    end

    def +(pol)
      if pol.kind_of?(Float) or pol.kind_of?(Integer)
        @terms[0] += pol
        return self
      end
      unless pol.kind_of?(Polynomial)
        throw StandardError
      end
      pol.terms.each do |term|
        finded_term = find_term(term)
        unless finded_term.nil?
          term
        end
      end
    end
  end
end


