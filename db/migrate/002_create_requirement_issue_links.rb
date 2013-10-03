class CreateRequirementIssueLinks < ActiveRecord::Migration
  def change
    create_table :requirement_issue_links do |t|
      t.integer :req
      t.integer :issue_link
      t.boolean :direct, :default => false
    end
  end
end
