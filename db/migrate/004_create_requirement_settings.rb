class CreateRequirementSettings < ActiveRecord::Migration
  def self.up
    create_table :requirement_settings do |t|
      t.column :project_id, :integer
      t.column :prefix_list, :string
    end
  end

  def self.down
    drop_table :requirement_settings
  end
end
