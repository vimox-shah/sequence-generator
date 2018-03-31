module SequenceGenerator
  class SequenceSerializer < BaseSerializer
    attributes :id, :sequence_prefix, :sequential_id, :start_at, :valid_from, :valid_till,
    :reset_from_next_year, :purpose, :financial_year_start, :financial_year_end, :scope
  end
end