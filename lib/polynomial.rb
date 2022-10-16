module PolynomialComputations
  class Polynomial
    attr_accessor :terms

    def initialize
      @terms = []
      @changed = false
      @degree = 0
    end

    def add_unordered(term)
      @terms.push term
      @changed = true
    end

    def add(term)
      add_unordered term

      order
    end

    def order
      @terms.sort! { |t1, t2| t1.degree <=> t2.degree }
    end

    def degree
      if @changed
        @changed = terms.map { |term| term.degree }.max
      end

      @degree
    end
  end

  class Term
    attr_accessor :factors

    def initialize
      @factors = []
      @degree = 0
      @changed = false
    end

    def add_unordered(factor)
      @factors.push factor
      @changed = true
    end

    def add(factor)
      add_unordered factor

      order
    end

    def order
      @factors.sort! do |f1, f2|
        if f1.base.nil?
          -1
        elsif f2.base.nil?
          1
        else
          f1.base <=> f2.base
        end
      end
    end

    def degree
      if @changed
        @degree = @factors.map { |factor| factor.exp }.sum
      end

      @degree
    end
  end

  class Factor
    attr_accessor :coef, :base, :exp

    def initialize(coef, base, exp)
      @coef = coef
      @base = base
      @exp = exp
    end
  end
end