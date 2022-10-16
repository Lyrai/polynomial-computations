module PolynomialComputations
  class Simplifier
    def initialize(tree)
      @tree = tree
    end

    def simplify
      visit @tree

      @tree
    end

    def visit_bin_op_node(node)
      if node.token.type == TokenType::MULTIPLY || node.token.type == TokenType::DIVIDE
        left_token = node.left.token
        if left_token.type == TokenType::PLUS || left_token.type == TokenType::MINUS
          node.token = left_token
          left = BinOpNode.new(node.token, left: node.left.left, right: node.right.clone)
          left.left.set_parent left
          left.right.set_parent left
          left.set_parent node
          node.left = left

          right = BinOpNode.new(node.token, left: node.left.right, right: node.right.clone)
          right.left.set_parent right
          right.right.set_parent right
          right.set_parent node
          node.right = right
        end
      end

      if node.token.type == TokenType::MULTIPLY
        right_token = node.right.token
        if right_token.type == TokenType::PLUS || right_token.type == TokenType::MINUS
          node.token = right_token
          left = BinOpNode.new(node.token, left: node.left.clone, right: node.right.left)
          left.left.set_parent left
          left.right.set_parent left
          left.set_parent node
          node.left = left

          right = BinOpNode.new(node.token, left: node.left.clone, right: node.right.right)
          right.left.set_parent right
          right.right.set_parent right
          right.set_parent node
          node.right = right
        end
      end

      visit node.left
      visit node.right
    end

    def visit_un_op_node(node)

    end

    def visit_var_node(node)

    end

    def visit_number_node(node)

    end

    def visit(node)
      node.accept self
    end
  end
end