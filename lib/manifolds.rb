# frozen_string_literal: true

require "yaml"
require "thor"

Dir[File.join(__dir__, "manifolds", "**", "*.rb")].sort.each do |file|
  require file
end

module Manifolds
  class Error < StandardError; end
end
