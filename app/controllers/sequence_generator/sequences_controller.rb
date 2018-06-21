module SequenceGenerator
  class SequencesController < ApplicationController
    around_action :transactions_filter, only: %i[create update]


    def create
      sequence = Sequence.new(create_sequence_params)
      if sequence.save
        render json: sequence, serializer: SequenceSerializer
      else
        api_error(status: :unprocessable_entity,
                  message: 'sequence creation failed',
                  errors: sequence.errors)
      end
    end

    def update
      sequence = Sequence.find(params[:id])
      if sequence.update(update_sequence_params)
        render json: sequence, serializer: SequenceSerializer
      else
        api_error(status: :unprocessable_entity,
                  message: 'sequence update failed',
                  errors: sequence.errors)
      end
    end

    def index
      sequences = Sequence.where(scope: params[:branch_id], purpose: params[:purpose])
      if sequences.present?
        render json: {
            "sequence_generator/sequences": ActiveModel::Serializer::CollectionSerializer.new(sequences, serializer: SequenceSerializer)
        }, status: :ok
      else
        api_error(status: :unprocessable_entity,
                  message: 'Sequences Not found'
        )
      end
    end

    private

    def transactions_filter
      ActiveRecord::Base.transaction do
        yield
      end
    end


    def create_sequence_params
      params.permit(:sequence_prefix,
                    :sequential_id,
                    :start_at,
                    :valid_from,
                    :valid_till,
                    :reset_from_next_year,
                    :purpose,
                    :financial_year_start,
                    :financial_year_end,
                    :scope)
    end


    def update_sequence_params
      params.permit(:sequence_prefix,
                    :sequential_id,
                    :start_at,
                    :valid_from,
                    :valid_till,
                    :reset_from_next_year,
                    :purpose,
                    :financial_year_start,
                    :financial_year_end,
                    :scope)
    end


  end
end