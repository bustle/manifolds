# frozen_string_literal: true

require "thor"
require "fileutils"

# ManifoldsCLI provides command line interface functionality
# for creating and managing umbrella projects for data management.
class ManifoldsCLI < Thor
  desc "new_umbrella NAME", "Generate a new umbrella project for data management"
  def new_umbrella(name)
    directory_path = "./#{name}/projects"
    FileUtils.mkdir_p(directory_path)
    puts "Created umbrella project '#{name}' with a projects directory."
    # Generate Gemfile inside the new umbrella project
    File.open("./#{name}/Gemfile", "w") do |file|
      file.puts "source 'https://rubygems.org'"
      file.puts "gem 'thor'"
    end
    puts "Generated Gemfile for the umbrella project."
  end
end

if __FILE__ == $PROGRAM_NAME
  ManifoldsCLI.start(ARGV)
end
