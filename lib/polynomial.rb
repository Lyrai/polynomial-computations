module PolynomialComputations
  class Polynomial
    attr_accessor :terms

    def initialize(tree)
      @terms = []
      @degree_changed = false
      @terms_changed = false
      @degree = 0
      @tree = tree
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
        @degree_changed = terms.map { |term| term.degree }.max
      end

      @degree
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
          .map { |factor| factor.to_s }
          .unshift("-")
          .join ""
      end

      (@factors.size == 1 ? @factors : (@factors
        .reject {|factor| factor.exp == 0 && factor.coef == 1 }))
        .map { |factor| factor.to_s }
        .join ""
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
        strip_trailing_zero  @coef
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