require 'stringio'
require 'modeling'

module Rebus
  class Compiler
    
    model :code_prefix, :comment_prefix, :context do
      @code_prefix ||= Rebus.code_prefix
      @comment_prefix ||= Rebus.comment_prefix
      reset_lines
    end

    def reset_lines
      @current_line = 1
      @string_lines = []
    end

    def compile source
      return compile source do;end if !block_given?

      reset_lines
      parsed = parse source
      error = nil

      begin
        if source.is_a? File
          context.instance_eval parsed, source.path
        else
          context.instance_eval parsed
        end
      rescue ScriptError, StandardError => err
        error = err
      end
      if error
        raise prepare_error error
      end
      self
    end

    def parse source
      source = case source
      when String
        StringIO.new source
      when IO
        source
      else 
        raise "Unsupported source #{source.class}"
      end

      escaped_code_prefix = Regexp.escape @code_prefix
      line_regexp = /^\s*(#{@comment_prefix})?(#{escaped_code_prefix})?\s*(.+)\s*$/
      source.each_line.map{ parse_line _1, line_regexp }.compact.join "\n"
    end

    def parse_line line, regexp
      if line =~ regexp
        if $1 # comment
          @current_line += 1
          return ""
        else
          if $2 # code
            @current_line += 1
            return $3
          else # string
            @string_lines << @current_line + 1
            @current_line += 3
            return "yield <<-\"#{@code_prefix}\".chop\n#{$3}\n#{@code_prefix}"
          end
        end
      else # blank line
        @current_line += 1
        return "yield ''"
      end
    end

    private

    def prepare_error error
      lines = error.message.split("\n")
      path_regexp = /^(.*:)(\d+):(.*)/
      if lines[0] =~ path_regexp
        lineno = $2.to_i
        lineno -= @string_lines.map{ (lineno <=> _1) + 1 }.sum
        backtrace = [$1 + lineno.to_s, *error.backtrace]
        message = "#{$3}\n#{lines[1..]&.join "\n"}"
      elsif error.backtrace[0] =~ path_regexp
        lineno = $2.to_i
        lineno -= @string_lines.map{ _1 <= lineno ? _1 < lineno ? 2 : 1 : 0 }.sum
        backtrace = [$1 + lineno.to_s, *error.backtrace[1..]]
        message = "#{lines&.join "\n"}"
      else
        backtrace = error.backtrace
        message = error.message
      end
      new_error = SyntaxError.new message
      new_error.set_backtrace backtrace
      return new_error
    end
  end
end