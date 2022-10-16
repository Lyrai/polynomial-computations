module PolynomialComputations
  class PowerExpander
    def initialize(tree)
      @tree = tree
    end

    def expand
      visit @tree

      @tree
    end

    def visit_bin_op_node(node)
      if node.token.type == TokenType::POWER
        unless (node.left.kind_of? VarNode) || (node.left.kind_of? NumberNode)
          if node.right.value > 2
            right = node.clone
            right.right.set_token! Token.new(TokenType::NUMBER, right.right.value - 1)
            right.set_parent! node
            node.right = right
            node.set_token! Token.new(TokenType::MULTIPLY, '*')
          elsif node.right.value == 2
            right = node.left.clone
            node.right = right
            node.set_token! Token.new(TokenType::MULTIPLY, '*')
          elsif node.right.value == 1
            if node.parent.nil?
              @tree = node.left
            else
              node.parent.replace! node, node.left
            end
          elsif node.right.value == 0
            new_node = NumberNode.new(Token.new(TokenType::NUMBER, 1))
            if node.parent.nil?
              @tree = new_node
            else
              node.parent.replace! node, new_node
            end
          else
            node.right.set_token! Token.new(TokenType::NUMBER, node.right.value * -1)
            new_node = BinOpNode.new(Token.new(TokenType::DIVIDE, '/'), left: NumberNode.new(Token.new(TokenType::NUMBER, 1)), right: node)
            if node.parent.nil?
              @tree = new_node
            else
              node.parent.replace! node, new_node
            end

            node.set_parent! new_node
          end
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
