class AddVersioning < ActiveRecord::Migration
  def self.up
    Requirement.create_versioned_table
  end
  def self.down
    Requirement.drop_versioned_table
  end
end
