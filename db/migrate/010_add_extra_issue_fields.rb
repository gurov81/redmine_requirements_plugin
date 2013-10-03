class AddExtraIssueFields < ActiveRecord::Migration
  def self.up 
    add_column :issues, :requirement_id, :integer, {:default => nil, :null => true}
  end

  def self.down
    remove_column :issues, :requirement_id
  end
end
