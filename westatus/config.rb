require "toml"

class Config
  attr_reader :data

  def initialize(path = "~/.config/westatus/config.toml")
    path = File.expand_path(path)

    if File.exist?(path)
      @data = TOML.load_file(path)
    end
  end
end
