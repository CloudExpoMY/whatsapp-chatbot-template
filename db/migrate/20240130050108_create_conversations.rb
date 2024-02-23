class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :current_step
      t.jsonb :data

      t.timestamps
    end
  end
end
