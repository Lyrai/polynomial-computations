module PolynomialComputations
=begin
  expression: term ((+|-) term)*
  term: factor ((*|/) factor)*
  factor: ((+|-) factor) | power
  power: primary (^ power)?
  primary: var | num | '(' expression ')'
  var: [a-z]
  num [0-9]+(.[0-9]*)
=end

  class Parser
    attr_accessor :tokens
    def initialize(tokens)
      @tokens = tokens
      @pos = 0
    end

    def parse
      expression
    end

    def expression
      p "Expression"
      node = term
      op = match_token [TokenType::PLUS, TokenType::MINUS]
      until op.nil?
        node = BinOpNode.new(op, left: node, right: term)
        op = match_token [TokenType::PLUS, TokenType::MINUS]
      end

      node
    end

    def term
      p "Term"
      node = factor
      op = match_token [TokenType::MULTIPLY, TokenType::DIVIDE]
      until op.nil?
        node = BinOpNode.new(op, left: node, right: factor)
        op = match_token [TokenType::MULTIPLY, TokenType::DIVIDE]
      end

      node
    end

    def factor
      p "Factor"
      unary = match_token [TokenType::MINUS, TokenType::PLUS]
      unless unary.nil?
        return UnOpNode.new(unary, factor)
      end

      power
    end

    def power
      p "Power"
      base = primary
      exp_token = match_token [TokenType::POWER]
      unless exp_token.nil?
        base = BinOpNode.new(exp_token, left: base, right: power)
        op = match_token [TokenType::POWER]
      end

      base
    end

    def primary
      p "Primary"
      token = match_token [TokenType::LPAR, TokenType::VAR, TokenType::NUMBER]
      if token.nil?
        raise StandardError.new("Unexpected token " + @tokens[@pos].value)
      end

      if token.type == TokenType::LPAR
        node = expression
        if match_token([TokenType::RPAR]).nil?
          raise StandardError.new("Expected ) at the end of the expression")
        end

        node
      elsif token.type == TokenType::VAR
        VarNode.new(token)
      elsif token.type == TokenType::NUMBER
        NumberNode.new(token)
      end
    end

    def match_token(types)
      if @pos >= @tokens.size
        return nil
      end

      types.each do |type|
        if @tokens[@pos].type == type
          @pos += 1
          return @tokens[@pos - 1]
        end
      end

      nil
    end
  end

  class Node
    attr_accessor :token, :value
    def initialize(token)
      @token = token
      @value = token.value
    end
  end

  class BinOpNode < Node
    attr_accessor :left, :right

    def initialize(token, left: nil, right: nil)
      super token
      @left = left
      @right = right
    end
  end

  class UnOpNode < Node
    attr_accessor :operand

    def initialize(token, operand)
      super token
      @operand = operand
    end
  end

  class VarNode < Node
    attr_accessor :name

    def initialize(token)
      super token
      @name = token.value
    end
  end

  class NumberNode < Node
    attr_accessor :value

    def initialize(token)
      super token
      @value = Float(token.value)
    end
  end
end