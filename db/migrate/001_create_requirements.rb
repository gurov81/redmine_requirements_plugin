class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.string :project_id
      t.string :text
      t.string :req_id
    end
    add_index :requirements, :project_id
  end
end
