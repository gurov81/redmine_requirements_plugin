class CreateRequirementIssueLinks < ActiveRecord::Migration
  def change
    create_table :requirement_issue_links do |t|
      t.integer :req
      t.integer :issue_link
      t.integer :link_type
    end
    add_index :requirement_issue_links, :req
    add_index :requirement_issue_links, :issue_link
  end
end
