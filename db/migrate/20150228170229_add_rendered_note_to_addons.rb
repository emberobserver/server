class AddRenderedNoteToAddons < ActiveRecord::Migration
  def up
    add_column :addons, :rendered_note, :text
    Addon.where('note is not null').each do |addon|
      addon.rendered_note = GitHub::Markdown.to_html(addon.note, :gfm)
      addon.save
    end
  end

  def down
    remove_column :addons, :rendered_note
  end
end
