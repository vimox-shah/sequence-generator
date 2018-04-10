require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/class/attribute_accessors'

module SequenceGenerator
  module ActsAsSequenced
    extend ActiveSupport::Concern
    DEFAULT_OPTIONS = {
        purpose: 'Sequence',
        sequential_id: 0,
        start_at: 1
    }.freeze

    ColumnWithSamePurposeExists = Class.new(StandardError)

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def act_as_sequenced(options= {})
        unless defined?(sequenced_options)
          include SequenceGenerator::ActsAsSequenced::InstanceMethods

          mattr_accessor :sequenced_options, instance_accessor: false
          self.sequenced_options = []
        end
        before_validation :set_sequential_ids
        options = DEFAULT_OPTIONS.merge(options)
        column_name = options[:column]
        purpose = options[:purpose]

        if sequenced_options.any? { |options| options[:column] == column_name && options[:purpose] == purpose }
          raise(ColumnWithSamePurposeExists, <<-MSG.squish)
              Tried to set #{column_name} as sequenced but there was already a
              definition here. Did you accidentally call acts_as_sequenced
              multiple times on the same column with same purpose?
          MSG
        else
          sequenced_options << options
        end
      end
    end

    module InstanceMethods
      def set_sequential_ids
        self.class.base_class.sequenced_options.each do |options|
          unless options[:column].present?
            sequence = Sequence.where(purpose: options[:purpose], scope: send(options[:scope]))
                           .where('valid_from <= ? AND valid_till >= ?', Time.now, Time.now).first
            unless self.as_json[options[:column]].present?
              if sequence
                assign_attributes(options[:column]=> sequence.generate_sequence_number)
              else
                original_sequence = Sequence.where(purpose: options[:purpose], scope: send(options[:scope])).last
                if original_sequence.nil?
                  errors.add(:sequential_id, 'Sequence is not created')
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
                                                            sequential_id: 1))
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
                  assign_attributes(options[:column]=> sequence.generate_sequence_number)
                end
              end
            end
          end

        end
      end
    end
  end
end

# ActiveRecord::Base.send(:include, SequenceGenerator::ActsAsSequenced)
