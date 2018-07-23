require "todoable/version"
require 'rest-client'
require 'byebug'

module Todoable
  class ToDoList
    def self.authenticate
      response = RestClient::Request.execute(method: :post, url: "http://todoable.teachable.tech/api/authenticate", user: ENV.fetch(todoable_username), password: ENV.fetch(todoable_password))
      @token = JSON.parse(response)["token"]
    end

    def self.get_lists
      authenticate
      response = RestClient::Request.execute(method: :get, url: "http://todoable.teachable.tech/api/lists", headers: headers)
      JSON.parse(response)["lists"]
    end

    def self.get_list(id)
      authenticate
      response = RestClient::Request.execute(method: :get, url: "http://todoable.teachable.tech/api/lists/#{id}", headers: headers)
      JSON.parse(response)
    end

    def self.create_list(name)
      payload = %Q{{"list":{"name":"#{name}" }}}
      authenticate
      response = RestClient::Request.execute(method: :post, url: "http://todoable.teachable.tech/api/lists", headers: headers, payload: payload)
      response
    end

    def self.update_list(list_id, name)
      payload = %Q{{"list":{"name":"#{name}" }}}
      authenticate
      response = RestClient::Request.execute(method: :patch, url: "http://todoable.teachable.tech/api/lists/#{list_id}", headers: headers, payload: payload)
      response
    end

    def self.create_list_item(list_id, item_name)
      payload = %Q{{"item":{"name": "#{item_name}" }}}
      authenticate
      response = RestClient::Request.execute(method: :post, url: "http://todoable.teachable.tech/api/lists/#{list_id}/items", headers: headers, payload: payload)
      response
    end

    def self.finish_list_item(list_id, item_id)
      authenticate
      response = RestClient::Request.execute(method: :put, url: "http://todoable.teachable.tech/api/lists/#{list_id}/items/#{item_id}/finish", headers: headers)
      response
    end

    def self.delete_list_item(list_id, item_id)
      authenticate
      response = RestClient::Request.execute(method: :delete, url: "http://todoable.teachable.tech/api/lists/#{list_id}/items/#{item_id}", headers: headers)
      response
    end

    def self.delete_list(id)
      authenticate
      response = RestClient::Request.execute(method: :delete, url: "http://todoable.teachable.tech/api/lists/#{id}", headers: headers)
      response
    end

    def self.headers
      { accept: "application/json", content_type: "application/json", authorization: "Token token=\"#{@token}\"" }
    end

    private_class_method :headers

  end
end
