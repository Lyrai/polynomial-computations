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
        old_token = node.token
        if left_token.type == TokenType::PLUS || left_token.type == TokenType::MINUS
          node.set_token! left_token
          old_right = node.right

          right = BinOpNode.new(old_token, left: node.left.right, right: old_right.clone)
          right.left.set_parent! right
          right.right.set_parent! right
          right.set_parent! node
          node.right = right

          left = BinOpNode.new(old_token, left: node.left.left, right: old_right.clone)
          left.left.set_parent! left
          left.right.set_parent! left
          left.set_parent! node
          node.left = left
        end
      end

      if node.token.type == TokenType::MULTIPLY
        right_token = node.right.token
        old_token = node.token
        if right_token.type == TokenType::PLUS || right_token.type == TokenType::MINUS
          node.set_token! right_token
          old_left = node.left
          left = BinOpNode.new(old_token, left: old_left.clone, right: node.right.left)
          left.left.set_parent! left
          left.right.set_parent! left
          left.set_parent! node
          node.left = left

          right = BinOpNode.new(old_token, left: old_left.clone, right: node.right.right)
          right.left.set_parent! right
          right.right.set_parent! right
          right.set_parent! node
          node.right = right
        end
      end

      visit node.left
      visit node.right
    end

    def visit_var_node(node) end

    def visit_number_node(node) end

    def visit(node)
      node.accept self
    end
  end
end