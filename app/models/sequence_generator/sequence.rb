require_relative '../concerns/act_as_sequenced'
module SequenceGenerator
  class Sequence < ApplicationRecord
    include SequenceGenerator::ActsAsSequenced

    before_validation :validate_sequential_id

    def validate_sequential_id
      validates_presence_of :sequential_id, :purpose
    end

    def generate_sequence_number
      sequence_number = "%05d" % (sequential_id + 1).to_s
      generated_sequential_id = "#{sequence_prefix}#{sequence_number}"
      self.update(sequential_id: sequential_id + 1)
      return generated_sequential_id
    end

  end
end
