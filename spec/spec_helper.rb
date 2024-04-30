# frozen_string_literal: true

# spec/spec_helper.rb

RSpec.configure do |config|
  config.before(:suite) do
    # Redirect all logger output to /dev/null
    Logger.new(File.open(File::NULL, "w"))
  end
end
