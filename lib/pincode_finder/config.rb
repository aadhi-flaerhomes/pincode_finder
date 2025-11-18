module PincodeFinder
  class Config
    attr_accessor :github_owner, :github_repo, :github_token

    def initialize
      @github_owner = nil
      @github_repo  = nil
      @github_token = nil
    end
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end
end
