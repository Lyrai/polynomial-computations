module PolynomialComputations
  class Lexer
    def initialize(str)
      @input = str
    end

    def tokens
      i = 0
      tokens = []
      while i < @input.size

        char = @input[i]
        case char
        when 'a'..'z'
          tokens.push(Token.new(TokenType::VAR, @input[i]))
        when '0'..'9'
          j = i
          while ('0'..'9').include?(@input[j])
            j += 1
          end
          if @input[j] == '.'
            j += 1
          end
          while ('0'..'9').include?(@input[j])
            j += 1
          end
          j -= 1
          tokens.push(Token.new(TokenType::NUMBER, Float(@input[i..j])))
          i = j
        when '+'
          tokens.push(Token.new(TokenType::PLUS, char))
        when '-'
          tokens.push(Token.new(TokenType::MINUS, char))
        when '*'
          tokens.push(Token.new(TokenType::MULTIPLY, char))
        when '/'
          tokens.push(Token.new(TokenType::DIVIDE, char))
        when '('
          tokens.push(Token.new(TokenType::LPAR, char))
        when ')'
          tokens.push(Token.new(TokenType::RPAR, char))
        when '^'
          tokens.push(Token.new(TokenType::POWER, char))
        when /[ \n\t\r]/
        else
          raise ArgumentError.new("Unexpected symbol " + char)
        end
        i += 1
      end

      tokens
    end
  end

  class Token
    attr_accessor :type, :value
    def initialize(type, value)
      @type = type
      @value = value
    end
  end

  module TokenType
    NUMBER = 0
    VAR = 1
    PLUS = 2
    MINUS = 3
    DIVIDE = 4
    MULTIPLY = 5
    POWER = 6
    LPAR = 7
    RPAR = 8
  end
end
