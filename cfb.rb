require 'swagger_client'
SwaggerClient.configure { |c| [c.debugging = false] }


module Cfb
  def self.api
    SwaggerClient::GamesApi.new()
  end
end