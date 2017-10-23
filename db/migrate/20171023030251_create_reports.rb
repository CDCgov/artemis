class CreateReports < ActiveRecord::Migration[5.1]
  def change
    create_table :reports do |t|
      t.string :requestor
      t.string :type
      t.jsonb  :data, default: {}
      t.timestamps
    end
  end
end
