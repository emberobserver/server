class RemoveRenderedNoteFromAddon < ActiveRecord::Migration[5.1]
  def change
    remove_column :addons, :rendered_note, :text
  end
end
