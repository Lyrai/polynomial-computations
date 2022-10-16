module PolynomialComputations
=begin
  expression: term ((+|-) term)*
  term: factor ((*|/) factor)*
  factor: (- factor) | power
  power: primary (^ num)?
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
      expression nil
    end

    def expression(parent)
      node = term parent
      op = match_token [TokenType::PLUS, TokenType::MINUS]
      until op.nil?
        right = term parent
        new_node = BinOpNode.new(op, left: node, right: right)
        node.set_parent new_node
        right.set_parent new_node
        new_node.set_parent parent
        node = new_node
        op = match_token [TokenType::PLUS, TokenType::MINUS]
      end

      node
    end

    def term(parent)
      node = factor parent
      op = match_token [TokenType::MULTIPLY, TokenType::DIVIDE]
      until op.nil?
        right = factor parent
        new_node = BinOpNode.new(op, left: node, right: right)
        node.set_parent new_node
        right.set_parent new_node
        new_node.set_parent parent
        node = new_node
        op = match_token [TokenType::MULTIPLY, TokenType::DIVIDE]
      end

      node
    end

    def factor(parent)
      unary = match_token [TokenType::MINUS]
      unless unary.nil?
        inner = factor parent
        new_node = BinOpNode.new(Token.new(TokenType::MULTIPLY, '*'), left: NumberNode.new(Token.new(TokenType::NUMBER, -1.0)), right: inner)
        new_node.parent = new_node
        inner.set_parent new_node
        return new_node
      end

      power parent
    end

    def power(parent)
      base = primary parent
      exp_token = match_token [TokenType::POWER]
      unless exp_token.nil?
        num_token = match_token [TokenType::NUMBER]
        unless num_token.nil?
          raise StandardError.new "Unexpected token"
        end

        right = NumberNode.new(num_token)
        new_node = BinOpNode.new(exp_token, left: base, right: right)
        base.set_parent new_node
        right.set_parent new_node
        new_node.set_parent parent
        base = new_node
      end

      base
    end

    def primary(parent)
      token = match_token [TokenType::LPAR, TokenType::VAR, TokenType::NUMBER]
      if token.nil?
        raise StandardError.new("Unexpected token " + @tokens[@pos].value)
      end

      if token.type == TokenType::LPAR
        node = expression parent
        if match_token([TokenType::RPAR]).nil?
          raise StandardError.new("Expected ) at the end of the expression")
        end

        node
      elsif token.type == TokenType::VAR
        node = VarNode.new(token)
        node.set_parent parent
        node
      elsif token.type == TokenType::NUMBER
        node = NumberNode.new(token)
        node.set_parent parent
        node
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
    attr_accessor :parent
    def initialize(token)
      @token = token
      @value = token.value
      @parent = nil
    end

    def set_parent(parent)
      @parent = parent
    end

    def value
      @value
    end

    def token
      @token
    end

    def set_token(token)
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

    def accept(visitor)
      visitor.visit_bin_op_node self
    end

    def print(depth = 0)
      puts " " * depth + "BinOp: " + @value
      @left.print depth + 1
      @right.print depth + 1
    end
  end

  class UnOpNode < Node
    attr_accessor :operand

    def initialize(token, operand)
      super token
      @operand = operand
    end

    def accept(visitor)
      visitor.visit_un_op_node self
    end

    def print(depth = 0)
      puts " " * depth + "UnOp: " + @value
      @operand.print depth + 1
    end
  end

  class VarNode < Node
    attr_accessor :name

    def initialize(token)
      super token
      @name = token.value
    end

    def accept(visitor)
      visitor.visit_var_node self
    end

    def print(depth = 0)
      puts " " * depth + "Var: " + @value
    end
  end

  class NumberNode < Node
    attr_accessor :value

    def initialize(token)
      super token
      @value = Float(token.value)
    end

    def accept(visitor)
      visitor.visit_number_node self
    end

    def print(depth = 0)
      puts " " * depth + "Number: " + @value.to_s
    end
  end
end