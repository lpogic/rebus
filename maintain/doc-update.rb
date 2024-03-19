require 'rebus'
gemspec = Gem::Specification.load("./#{Dir["*.gemspec"].first}")

def write_file filepath, &b
  filepath.split("/").reduce do |path, next_part|
    Dir.mkdir path if not Dir.exist? path
    "#{path}/#{next_part}"
  end
  File.open filepath, "w", &b
end

def base_dir
  dir = Dir.getwd
  dir.end_with?("maintain") ? File.dirname(dir) : dir
end

def compile input_file, output_file, gemspec
  code = proc do |path|
    "```RUBY\n" +  File.read("#{base_dir}/#{path}") + "\n```"
  end
  sample_index = 1
  sample = proc do |title, source|
    result = "### #{sample_index}. #{title}\n#{ code.(source) }\n"
    sample_index += 1
    result
  end
  base_dir = self.base_dir

  write_file output_file do |f|
    Rebus.compile_file input_file do |line|
      f << line << "\n"
    end
  end
end

compile "#{base_dir}/doc/draft/wiki.md.rbs", "#{base_dir}/doc/wiki/README.md", gemspec
compile "#{base_dir}/doc/draft/readme.md.rbs", "#{base_dir}/README.md", gemspec
