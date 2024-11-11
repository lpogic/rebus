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
      @mode = :code
      @text_line_begin = "yield <<-\"#{@code_prefix}\".chop\n"
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

      result = source.each_line.map{ parse_line _1 }.compact.join "\n"
      result + "\n" + code("")
    end

    private

    def parse_line line
      stripped = line.strip
      if stripped == ""
        blank
      elsif stripped.start_with? @code_prefix
        code stripped[@code_prefix.length..]
      elsif stripped.start_with? @comment_prefix
        code ""
      else
        text @strip_lines ? stripped : line.chomp
      end
    end

    def text line
      out = ""
      if @mode == :code
        out << @text_line_begin
      end
      out << line
      @mode = :text
      out
    end

    def code line
      out = ""
      if @mode == :text
        out << @text_line_end
      end
      out << line
      @mode = :code
      out
    end

    def blank
      ""
    end

    def prepare_error error, parsed
      lines = error.message.split("\n")
      path_regexp = /^(.*:)(\d+):(.*)/
      if lines[0] =~ path_regexp
        lineno = reduce_error_lineno $2.to_i, parsed
        backtrace = [$1 + lineno.to_s, *error.backtrace]
        message = "#{$3}\n#{lines[1..]&.join "\n"}"
      elsif error.backtrace[0] =~ path_regexp
        lineno = reduce_error_lineno $2.to_i, parsed
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

    def reduce_error_lineno error_lineno, parsed
      lineno = 0
      parsed.each_line.each_with_index do |line, i|
        break if i >= error_lineno
        lineno += 1 if line != @text_line_begin && line != @text_line_end
      end
      lineno
    end
  end
end