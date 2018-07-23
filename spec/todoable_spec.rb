require "spec_helper"

RSpec.describe Todoable do
  let(:list_name) { "Things for dog to do" }

  it "has a version number" do
    expect(Todoable::VERSION).not_to be nil
  end

  describe "get_lists" do
    it "gets a list of todo lists" do
      find_or_create_list(list_name)
      response = Todoable::ToDoList.get_lists
      expect(response.map{ |list| list["name"]}).to include(list_name)
    end
  end

  describe "get_list" do
    it "gets a specific todo list by id" do
      to_do_list = find_or_create_list("Things My Dog Likes")
      response = Todoable::ToDoList.get_list(to_do_list["id"])
      expect(response["name"]).to eq "Things My Dog Likes"
    end

    it "gets all the items from the list" do
      to_do_list = find_or_create_list("Things My Dog Likes")
      Todoable::ToDoList.create_list_item(to_do_list["id"], "Chase motorcycle")
      Todoable::ToDoList.create_list_item(to_do_list["id"], "Chew up shoes")
      Todoable::ToDoList.create_list_item(to_do_list["id"], "Get that skunk!")
      response = Todoable::ToDoList.get_list(to_do_list["id"])
      expect(response["items"].map{ |item| item["name"] }).to include("Chase motorcycle")
      expect(response["items"].map{ |item| item["name"] }).to include("Chew up shoes")
      expect(response["items"].map{ |item| item["name"] }).to include("Get that skunk!")
    end
  end

  describe "delete_list" do
    it "deletes an existing list" do
      test_list = find_or_create_list("Things My Dog Needs to Destroy")
      expect(test_list).not_to be_nil
      Todoable::ToDoList.delete_list(test_list["id"])
      test_list = get_list_by_name("Things My Dog Needs to Destroy")
      expect(test_list).to be_nil
    end

    describe "update_list" do
      it "changes the name of the list" do
        delete_list_by_name("Things not to do at work today")
        to_do_list = delete_and_recreate_list("Things to do at work today")
        Todoable::ToDoList::update_list(to_do_list["id"], "Things not to do at work today")
        to_do_list = Todoable::ToDoList.get_list(to_do_list["id"])
        expect(to_do_list["name"]).to eq("Things not to do at work today")
      end
    end
  end

  describe "create_list" do
    it "creates a new list" do
      # delete the list if it already exists
      delete_list_by_name("Things My Dog Needs to Destroy")
      response = Todoable::ToDoList.create_list( "Things My Dog Needs to Destroy")
      expect(JSON.parse(response)["name"]).to eq "Things My Dog Needs to Destroy"
    end
  end

  describe "create_list_item" do
    it "creates a new list item" do
      to_do_list = delete_and_recreate_list("Things My Dog Needs to Destroy")
      list_items = Todoable::ToDoList.get_list(to_do_list["id"])["items"]
      expect(list_items).to be_empty
      Todoable::ToDoList.create_list_item(to_do_list["id"], "Get the stick")
      list_item_names = Todoable::ToDoList.get_list(to_do_list["id"])["items"].map{ |item| item["name"] }
      expect(list_item_names).to include("Get the stick")
    end
  end

  describe "finish_list_item" do
    it "marks a list item as 'finished'" do
      to_do_list = delete_and_recreate_list("Things My Dog Likes")
      Todoable::ToDoList.create_list_item(to_do_list["id"], "Chase motorcycle")
      list_item = find_list_item(to_do_list["id"], "Chase motorcycle")
      expect(list_item["finished_at"]).to be_nil
      Todoable::ToDoList.finish_list_item(to_do_list["id"],list_item["id"])
      list_item = find_list_item(to_do_list["id"], "Chase motorcycle")
      expect(list_item["finished_at"]).not_to be_nil
    end
  end

  describe "delete_list_item" do
    it "deletes an item from a list" do
      to_do_list = delete_and_recreate_list("Things My Dog Likes")
      Todoable::ToDoList.create_list_item(to_do_list["id"], "Chase motorcycle")
      list_item = find_list_item(to_do_list["id"], "Chase motorcycle")
      expect(list_item).not_to be_nil
      Todoable::ToDoList.delete_list_item(to_do_list["id"], list_item["id"])
      list_item = find_list_item(to_do_list["id"], "Chase motorcycle")
      expect(list_item).to be_nil
    end
  end

  def find_or_create_list(name)
    to_do_list = get_list_by_name(name)
    Todoable::ToDoList.create_list(name) unless to_do_list
    get_list_by_name(name)
  end

  def delete_list_by_name(name)
    to_do_list = get_list_by_name(name)
    Todoable::ToDoList.delete_list(to_do_list["id"]) if to_do_list
  end

  def delete_and_recreate_list(name)
    to_do_list = get_list_by_name(name)
    Todoable::ToDoList.delete_list(to_do_list["id"]) if to_do_list
    Todoable::ToDoList.create_list(name)
    get_list_by_name(name)
  end

  def get_list_by_name(name)
    lists = Todoable::ToDoList.get_lists
    lists.select{ |list| list["name"] == name }.first
  end

  def find_list_item(to_do_list_id, name)
    to_do_list = Todoable::ToDoList.get_list(to_do_list_id)
    to_do_list["items"].select{ |item| item["name"] == name }.first
  end
end
