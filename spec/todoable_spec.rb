require "spec_helper"

RSpec.describe Todoable do
  it "has a version number" do
    expect(Todoable::VERSION).not_to be nil
  end

  describe "#lists" do
    it "gets a list of todo lists" do
      lists = Todoable.lists
    end
  end
end
