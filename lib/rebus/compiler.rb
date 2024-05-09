require 'stringio'
require 'modeling'

module Rebus
  class Compiler
    
    model :code_prefix, :comment_prefix, :context do
      @code_prefix ||= Rebus.code_prefix
      @comment_prefix ||= Rebus.comment_prefix
    end

    def reset
      @current_line = 1
      @string_lines = []
      @mode = :code
    end

    def compile source
      reset
      parsed = parse source
      error = nil
      puts parsed

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

      line_regexp = /^\s*(#{@comment_prefix})?(#{@code_prefix})?\s*(.*)\s*$/
      result = source.each_line.map{ parse_line _1, line_regexp }.compact.join "\n"
      result + "\n" + code("")
    end

    private

    def parse_line line, regexp
      line =~ regexp ? $1 ? comment : $2 ? code($3) : text($3) : blank
    end

    def comment
      nil
    end

    def code line
      out = ""
      if @mode == :text
        out << @code_prefix << "\n"
        @current_line += 1
      end
      out << line
      @current_line += 1
      @mode = :code
      out
    end

    def text line
      out = ""
      if @mode == :code
        out << "yield <<-\"#{@code_prefix}\".chop\n"
        @current_line += 1
      end
      out << line
      @current_line += 1
      @mode = :text
      out
    end

    def blank
      @current_line += 1
      ""
    end

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