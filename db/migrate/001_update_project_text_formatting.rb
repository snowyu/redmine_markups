
class UpdateProjectTextFormatting < ActiveRecord::Migration
  def self.up
    add_column :projects, :text_formatting, :string, :default => "", :null => false
  end

  def self.down
    remove_column :projects, :text_formatting
  end
end
