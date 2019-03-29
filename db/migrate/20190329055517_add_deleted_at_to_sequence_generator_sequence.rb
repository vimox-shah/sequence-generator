class AddDeletedAtToSequenceGeneratorSequence < ActiveRecord::Migration[5.2]
  def change
    add_column :sequence_generator_sequences, :deleted_at, :timestamp
  end
end
