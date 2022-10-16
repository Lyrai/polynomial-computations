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