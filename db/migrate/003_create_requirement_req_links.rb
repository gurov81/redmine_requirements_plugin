class CreateRequirementReqLinks < ActiveRecord::Migration
  def change
    create_table :requirement_req_links do |t|
      t.integer :req
      t.integer :req_link
      t.integer :link_type
    end
    add_index :requirement_req_links, :req
    add_index :requirement_req_links, :req_link
  end
end
