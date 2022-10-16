module PolynomialComputations
  class ConstantFolder

    def initialize(tree)
      @tree = tree
    end

    def fold
      visit @tree

      @tree
    end

    def visit_bin_op_node(node)
      visit node.left
      visit node.right

      if (node.left.kind_of? NumberNode) && (node.right.kind_of? NumberNode)
        value = case node.value
                when '+'
                  node.left.value + node.right.value
                when '-'
                  node.left.value - node.right.value
                when '*'
                  node.left.value * node.right.value
                when '/'
                  node.left.value / node.right.value
                when '^'
                  node.left.value ** node.right.value
                end
        new_node = NumberNode.new(Token.new(TokenType::NUMBER, value))
        if node.parent.nil?
          @tree = new_node
        else
          node.parent.replace! node, new_node
        end
      end
    end

    def visit_var_node(node) end

    def visit_number_node(node) end

    def visit(node)
      node.accept self
    end
  end
end