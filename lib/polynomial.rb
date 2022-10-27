require_relative 'lexer'
require_relative 'parser'
require_relative 'constant_folder'
require_relative 'power_expander'
require_relative 'simplifier'
require_relative 'polynomial_composer'

module PolynomialComputations
  class Polynomial
    attr_accessor :terms

    def initialize
      @terms = []
      @degree_changed = false
      @terms_changed = false
      @degree = 0
    end

    def self.from_s(str)
      l = Lexer.new str
      p = Parser.new l.tokens
      tree = p.parse
      f = ConstantFolder.new tree
      tree = f.fold
      e = PowerExpander.new tree
      tree = e.expand
      s = Simplifier.new tree
      tree = s.simplify
      c = PolynomialComposer.new tree
      c.compose
    end

    def add_unordered!(term)
      if term.empty?
        return
      end

      #puts "Add term: " + term.to_s + " size " + term.factors.size.to_s
      t = get_vars_compatible_term term
      if t.nil?
        @terms.push term
        @terms_changed = true
      else
        t.coef += term.coef
        if t.coef == 0
          @terms.delete t
        end
      end

      @degree_changed = true
      #puts "Self: " + self.to_s
    end

    def add!(term)
      add_unordered! term

      if @terms_changed
        order!
      end
    end

    def order!
      @terms.sort! { |t1, t2| t2.degree <=> t1.degree }
      @terms_changed = false
    end

    def get_vars_compatible_term(other)
      @terms.each do |term|
        if term == other
          return term
        end
      end

      nil
    end

    def degree
      if @degree_changed
        @degree = terms.map { |term| term.degree }.max
      end

      @degree
    end

    def derivative(base)
      p = Polynomial.new
      terms.each do |x|
        term = x.clone

        unless term.factors.size == 1
          buff = term.get_factor(base)
          unless buff == nil
            term.add!(Factor.new(buff.exp, nil, 0))
            buff.exp -= 1
            p.add_unordered!(term)
          end
        end
      end

      p.order!
      p
    end

    def to_s
      if @terms.size == 0
        return "0"
      end

      res = ""
      @terms.each_index do |i|
        term = @terms[i]
        if i > 0
          res += term.coef > 0 ? " + " + term.to_s : " - " + term.to_s[1..]
        else
          res += term.to_s
        end
      end

      res
    end

    def calculate(variables)
      res = 0
      @terms.each do |term|
        help_res = 1
        term.factors.each do |factor|
          help_res *= factor.coef
          if factor.base.nil?
            help_res *= 1
          else
            unless variables.keys.include?(factor.base)
              throw StandardError.new('Input data does not contain variable - ' + factor.base)
            end
            help_res *= variables[factor.base] ** factor.exp
          end
        end
        res += help_res
      end
      res
    end

    def valid_poly
      if degree == 0 and @terms[0].factors[0].base.nil?
        throw StandardError.new("Incorrect form of the polynomial")
      end
      if degree > 2
        throw StandardError.new("Finding roots for polynomial degree greater than 2 is not supported")
      end
      checker = @terms[0].factors[1].base
      @terms.each do |term|
        if term.factors.size > 2
          throw StandardError.new("Incorrect form of the polynomial")
        end
        if term.factors.size == 1
          return true
        elsif term.factors.size == 2 and term.factors[1].base != checker
          throw StandardError.new("Incorrect form of the polynomial")
        end
      end
      true
    end

    def roots
      if valid_poly
        if degree == 2
          d = @terms[1].coef ** 2 - 4 * @terms[0].coef * @terms[2].coef
          sqrt_dist = Math.sqrt(d)
          denom = (2.0 * @terms[0].coef)
          if d > 0
            x1 = (-@terms[1].coef + sqrt_dist) / denom
            x2 = (-@terms[1].coef - sqrt_dist) / denom
            puts 'First root - ' + x1.to_s + "\n" + "Second root - " + x2.to_s + "\n"
          else
            puts "No roots"
          end
        elsif degree == 1
          x = -@terms[1].coef / @terms[0].coef
          puts 'Root - ' + x.to_s + "\n"
        end
      end
    end

    def clone
      poly = Polynomial.new
      @terms.each do |term|
        poly.add_unordered!(term.clone)
      end
      poly.order!
      poly
    end

    def +(other)
      result = self.clone
      if other.kind_of?(Float) or other.kind_of?(Integer)
        t = Term.new
        t.add!(Factor.new(other, nil, 0))
        result.add!(t)
        return result
      end
      if other.kind_of?(Polynomial)
        other.terms.each do |term|
          result.add_unordered!(term)
        end
        result.order!
        return result
      end
      if other.kind_of?(String)
        result + Polynomial.from_s(other)
      end
    end

    def -(other)
      result = self.clone
      result + -1 * other
    end

    def *(other)
      result = self.clone
      if other.kind_of?(Float) or other.kind_of?(Integer)
        f = Factor.new(other, nil, 0)
        result.terms.each do |term|
          term.add!(f)
        end
      end
      if other.kind_of?(Polynomial) or other.kind_of?(String)
        return Polynomial.from_s("(" + result.to_s + ")"+"(" + other.to_s + ")")
      end
    end
  end

  class Term
    attr_accessor :factors

    def initialize
      @factors = [Factor.new(1, nil, 0)]
      @degree = 0
      @degree_changed = false
      @factors_changed = false
      @empty = true
    end

    def add_unordered!(factor)
      #puts "Add factor: " + factor.coef.to_s + " " + factor.base.to_s + " " + factor.exp.to_s
      if factor.exp == 0
        get_factor(nil).coef *= factor.coef
      else
        f = get_factor factor.base

        if f.nil?
          @factors.push factor
          @factors_changed = true
        else
          f.exp += factor.exp
        end

        @degree_changed = true
      end

      @empty = false
    end

    def add!(factor)
      add_unordered! factor

      if @factors_changed
        order!
      end
    end

    def order!
      @factors.sort! do |f1, f2|
        if f1.base.nil?
          -1
        elsif f2.base.nil?
          1
        else
          f1.base <=> f2.base
        end
      end

      @factors_changed = false
    end

    def get_factor(var)
      @factors.each do |factor|
        if factor.base == var
          return factor
        end
      end

      nil
    end

    def ==(other)
      if other.factors.size != @factors.size
        return false
      end

      @factors.each_index do |i|
        self_factor = @factors[i]
        other_factor = other.factors[i]
        if self_factor.base != other_factor.base || self_factor.exp != other_factor.exp
          return false
        end
      end

      true
    end

    def degree
      if @degree_changed
        @degree = @factors.map { |factor| factor.exp }.sum
      end

      @degree
    end

    def coef
      get_factor(nil).coef
    end

    def coef=(num)
      get_factor(nil).coef = num
    end

    def empty?
      @empty
    end

    def to_s
      if @empty
        return ""
      end

      if @factors.size == 1
        return @factors[0].to_s
      end

      if @factors[0].coef < 0
        return (@factors[1..])
                 .reject { |factor| factor.exp == 0 }
                 .map { |factor| factor.to_s }
                 .unshift(@factors[0].to_s[1..])
                 .unshift("-")
                 .join ""
      end

      @factors
        .reject { |factor| factor.exp == 0 && factor.base != nil }
        .map { |factor| factor.to_s }
        .join ""
    end

    def clone
      t = Term.new
      factors.each do |factor|
        t.add_unordered!(factor.clone)
      end
      t.order!
      t
    end

  end

  class Factor
    attr_accessor :coef, :base, :exp

    def initialize(coef, base, exp)
      @coef = coef
      @base = base
      @exp = exp
    end

    def to_s
      if @exp == 0
        strip_trailing_zero @coef
      elsif @exp == 1
        @base
      else
        @base + "^" + (strip_trailing_zero @exp)
      end
    end

    def strip_trailing_zero(n)
      n.to_s.sub(/\.?0+$/, '')
    end
  end
end
