class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.string :project_id
      t.string :req_id
      t.string :text
      t.string :url
      t.integer :version
      t.integer :user_id
      t.timestamp :updated_at
    end
    add_index :requirements, :req_id
    add_index :requirements, :project_id
  end
end
