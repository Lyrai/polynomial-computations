module PolynomialComputations
  class PolynomialComposer
    def initialize(tree)
      @tree = tree
      @terms = []
    end

    def compose

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

    def current_term
      @terms[@terms.size]
    end
  end
end