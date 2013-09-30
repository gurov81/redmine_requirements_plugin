class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.integer :project_id
      t.string :text
    end
    add_index :requirements, :project_id
  end
end
