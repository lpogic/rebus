require 'stringio'
require 'modeling'

module Rebus
  class Compiler
    
    model :code_prefix, :comment_prefix, :strip_lines, :context do
      @code_prefix ||= Rebus.code_prefix
      @comment_prefix ||= Rebus.comment_prefix
      @strip_lines ||= @strip_lines.nil? && Rebus.strip_lines
    end
        
    def reset
      @code_mode = true
      @text_line_begin = "yield <<-\"#{@code_prefix}\".chomp!.chomp\n"
      @text_line_end = "#{code_prefix}\n"
    end

    def compile source
      # yield to ether if no block given
      return compile(source){} unless block_given?
      reset
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
        raise prepare_error error, parsed
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
      result = source
        .each_line
        .lazy
        .map{ parse_line _1 }
        .compact
        .reduce{|acc, line| "#{acc}\n#{line}" }
      result + "\n" + code("")
    end

    private

    def parse_line line
      stripped = line.strip
      if stripped.start_with?(@code_prefix) || stripped == @code_prefix.strip
        code stripped[@code_prefix.length..] || ""
      elsif stripped.start_with?(@comment_prefix) || stripped == @comment_prefix.strip
        nil
      else
        text @strip_lines ? stripped : line.chomp
      end
    end

    def text line
      return line unless @code_mode
      @code_mode = false
      "#{@text_line_begin}#{line}"
    end

    def code line
      return line if @code_mode
      @code_mode = true
      "\n#{@text_line_end}#{line}"
    end

    def prepare_error error, parsed
      first_line, lines = *error.message.split("\n", 2)
      path_regexp = /^(.*:)(\d+):(.*)/
      if first_line =~ path_regexp
        lineno = reduce_error_lineno $2.to_i, parsed
        backtrace = [$1 + lineno.to_s, *error.backtrace]
        message = "#{$3}\n#{lines}"
      elsif error.backtrace[0] =~ path_regexp
        lineno = reduce_error_lineno $2.to_i, parsed
        backtrace = [$1 + lineno.to_s, *error.backtrace[1..]]
        message = error.message
      else
        backtrace = error.backtrace
        message = error.message
      end
      new_error = SyntaxError.new message
      new_error.set_backtrace backtrace
      return new_error
    end

    def reduce_error_lineno error_lineno, parsed
      lineno = 0
      parsed.each_line.each_with_index do |line, i|
        break if i >= error_lineno
        if line == @text_line_end
          lineno -= 1
        elsif line != @text_line_begin
          lineno += 1
        end
      end
      lineno
    end
  end
end