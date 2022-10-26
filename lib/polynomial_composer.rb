require_relative 'polynomial'

module PolynomialComputations
  class PolynomialComposer
    def initialize(tree)
      @tree = tree
      @terms = []
      @polynomial = Polynomial.new tree
    end

    def compose
      if @tree.kind_of? BinOpNode
        single_term = !([TokenType::PLUS, TokenType::MINUS].include? @tree.token.type)
        if single_term
          @terms.push Term.new
        end
        visit @tree
        if single_term
          current_term.order!
          @polynomial.add! current_term
        end
      else
        @terms.push Term.new
        visit @tree
        t = current_term
        t.order!
        @polynomial.add_unordered! t
      end



      @polynomial.order!
      @polynomial
    end

    def visit_bin_op_node(node)
      if node.token.type == TokenType::PLUS || node.token.type == TokenType::MINUS
        @terms.push Term.new
        visit node.left

        term = @terms.pop
        #if node.token.type == TokenType::MINUS
        #  term.add_unordered! Factor.new -1, nil, 0
        #end
        term.order!
        @polynomial.add_unordered! term

        @terms.push Term.new
        visit node.right

        term = @terms.pop
        if node.token.type == TokenType::MINUS
          term.add_unordered! Factor.new -1, nil, 0
        end
        term.order!
        @polynomial.add_unordered! term
      elsif node.token.type == TokenType::MULTIPLY
        visit node.left
        visit node.right
      elsif node.token.type == TokenType::DIVIDE
        visit node.left
        if node.right.kind_of? VarNode
          current_term.add_unordered! Factor.new 1, node.right.value, -1
        elsif node.right.kind_of? NumberNode
          current_term.add_unordered! Factor.new 1 / node.right.value, nil, 0
        else
          raise StandardError.new "Only numbers and single variables are supported in denominator"
        end
      elsif node.token.type == TokenType::POWER
        visit node.left
        last_factor.exp = node.right.value
      end
    end

    def visit_var_node(node)
      current_term.add_unordered! Factor.new 1, node.value, 1
    end

    def visit_number_node(node)
      current_term.add_unordered! Factor.new node.value, nil, 0
    end

    def visit(node)
      node.accept self
    end

    def current_term
      @terms[@terms.size - 1]
    end

    def last_factor
      term = current_term
      term.factors[term.factors.size - 1]
    end
  end
end