module PolynomialComputations
=begin
  expression: term ((+|-) term)*
  term: factor ((*|/) factor)*
  factor: ((+|-) factor) | power
  power: primary (^ primary)*
  primary: var | num | '(' expression ')'
  var: [a-z]
  num [0-9]+(.[0-9]*)
=end

  class Parser
    def initialize(tokens)
      @tokens = tokens
      position = 0
    end

    def parse
      expression
    end

    def expression
      node = term
      op = match [TokenType::PLUS, TokenType::MINUS]
      until op.nil?
        node = BinOpNode.new(op, left: node, right: term)
      end

      node
    end

    def term
      node = factor
      op = match [TokenType::MULTIPLY, TokenType::DIVIDE]
      until op.nil?
        node = BinOpNode.new(op, left: node, right: factor)
      end

      node
    end

    def factor
      unary = match [TokenType::MINUS, TokenType::PLUS]
      unless unary.nil?
        return UnOpNode.new(unary, factor)
      end

      power
    end

    def power

    end

    def match(types)
      types.each do |type|
        if @tokens[pos].type == type
          pos += 1
          return @tokens[pos - 1]
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
end