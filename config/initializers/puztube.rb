JsRoutes.setup do |c|
  c.prefix = "/"
end

module PuzTube
  def main_uri
    "http://localhost:3000"
  end

  def node_uri
    [ node_host, node_resource ].compact.join("/")
  end

  def node_host
    "http://localhost:5000"
  end

  def node_resource post=nil
    #[ "puznode", post ].compact.join("/")
    post
  end
end
