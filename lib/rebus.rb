require_relative 'rebus/compiler'
require_relative 'rebus/context'

module Rebus
  class << self
    attr_accessor :code_prefix
        attr_accessor :comment_prefix
    attr_accessor :home

    def compile_file filename, context = nil, **na, &block
      if !File.absolute_path? filename
        home = self.home || File.dirname(File.absolute_path?($0) ? $0 : Dir.getwd + "/" + $0)
        filename = home + "/" + filename
      end

      File.open filename do |file|
        compile file, context, **na, &block
      end
    end
  
    def compile source, context = nil, **na, &block
      case context
      when nil
        context = Context.generate **(block&.binding&.then{|b| b.local_variables.map{|v| [v, b.local_variable_get(v)]}.to_h} || {}), **na
        compile source, Compiler.new(context: context), &block
      when Binding
        context = Context.generate **context.local_variables.map{ [_1, context.local_variable_get(_1)] }.to_h, **na
        compile source, Compiler.new(context: context), &block
      when Hash
        context = Context.generate **context, **na
        compile source, Compiler.new(context: context), &block
      when Compiler
        if block
          context.compile source, &block
        else
          array = []
          context.compile source do |line|
            array << line
          end
          array.join "\n"
        end
      else
        compile source, Compiler.new(context: context), &block
      end
    end
  end
  
  self.code_prefix = "#\\|"
  self.comment_prefix = "//"
end
