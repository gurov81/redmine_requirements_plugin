class CreateRequirementReqLinks < ActiveRecord::Migration
  def change
    create_table :requirement_req_links do |t|
      t.integer :req
      t.integer :req_link
      t.boolean :direct, :default => false
    end
  end
end
