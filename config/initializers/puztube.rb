JsRoutes.setup do |c|
  c.prefix = "/puztube"
end

module PuzTube
  def self.main_host
    "https://mitdfa.com/puztube"
  end
  def self.node_host
    "https://mitdfa.com/puznode"
  end
end
