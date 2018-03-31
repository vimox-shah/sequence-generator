class CreateSequenceGeneratorSequences < ActiveRecord::Migration[5.0]
  def change
    create_table :sequence_generator_sequences do |t|

      t.column :sequence_prefix, :string
      t.column :sequential_id, :integer
      t.column :start_at, :integer
      t.column :valid_from, :date
      t.column :valid_till, :date
      t.column :reset_from_next_year, :boolean
      t.column :purpose, :string
      t.column :financial_year_start, :integer
      t.column :financial_year_end, :integer
      t.column :scope, :string

      t.timestamps
    end
  end
end
