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

    def fetch
      sequences = Sequence.where(scope: params[:branch_id], purpose: params[:purpose])
      if sequences.present?
        render json: sequences, root: sequences, status: :ok
      else
        api_error(status: :unprocessable_entity,
                  message: 'Sequences Not found'
        )
      end
    end

    def index
        sequence = Sequence.where(purpose: params[:purpose], scope: params[:scope])
                           .where('valid_from <= ? AND valid_till >= ?', Time.now, Time.now).first
        if sequence
          sequence_number = sequence.generate_sequence_number
          render json: { sequence_number: sequence_number, purpose: params[:purpose],
                         scope: params[:scope] }, status: :ok
        else
          original_sequence = Sequence.where(purpose: params[:purpose], scope: params[:scope]).last
          if original_sequence.nil?
            api_error(status: :unprocessable_entity,
                      message: 'Sequence is not Created')
          else
            valid_from = original_sequence.valid_from
            valid_till = original_sequence.valid_till
            new_start_at = original_sequence.sequential_id
            difference = (valid_till - valid_from).to_i
            new_valid_from = Date.today
            new_valid_till = new_valid_from + difference
            if original_sequence.reset_from_next_year
              sequence = Sequence.create!(original_sequence.as_json.except('id', 'start_at',
                                                                           'valid_from', 'valid_till',
                                                                           'sequential_id',
                                                                           'created_at', 'updated_at')
                                              .merge!(start_at: 1,
                                                      valid_from: new_valid_from,
                                                      valid_till: new_valid_till,
                                                      sequential_id: 0))
            else
              sequence = Sequence.create!(original_sequence.as_json.except('id', 'start_at',
                                                                           'valid_from', 'valid_till',
                                                                           'sequential_id',
                                                                           'created_at', 'updated_at')
                                              .merge!(start_at: new_start_at,
                                                      valid_from: new_valid_from,
                                                      valid_till: new_valid_till,
                                                      sequential_id: new_start_at))
            end
            sequence_number = sequence.generate_sequence_number
            render json: { sequence_number: sequence_number, purpose: params[:purpose],
                           scope: params[:scope] }, status: :ok
          end
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