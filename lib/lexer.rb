module PolynomialComputations
  class Lexer
    def initialize(str)
      @input = str
      @tokens = []
    end

    def tokens
      i = 0
      while i < @input.size

        char = @input[i]
        case char
        when 'a'..'z'
          @tokens.push(Token.new(TokenType::VAR, @input[i]))
        when '0'..'9'
          j = i
          while ('0'..'9').include?(@input[j])
            j += 1
          end
          j -= 1
          @tokens.push(Token.new(TokenType::NUMBER, Float(@input[i..j])))
          i = j
        when /[+\-*\/^]/
          @tokens.push(Token.new(TokenType::OPERATION, char))
        when '('
          @tokens.push(Token.new(TokenType::LPAR, char))
        when ')'
          @tokens.push(Token.new(TokenType::RPAR, char))
        when /[ \n\t\r]/
        else
          raise ArgumentError.new("Unexpected symbol " + char)
        end
        i += 1
      end

      @tokens
    end
  end

  class Token
    def initialize(type, value)
      @type = type
      @value = value
    end
  end

  module TokenType
    NUMBER = 0
    VAR = 1
    OPERATION = 2
    LPAR = 3
    RPAR = 4
  end
end