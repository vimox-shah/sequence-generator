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

          attr_accessor :sequence_generator_id
          mattr_accessor :sequenced_options, instance_accessor: false
          self.sequenced_options = []
        end
        options[:validation_options] ||= {on: :create}
        options[:validation_options][:on] ||= :create
        options = DEFAULT_OPTIONS.merge(options)
        before_validation options[:validation_options] do
          set_sequential_ids(options)
        end
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
      def set_sequential_ids(options)
        return if send(options[:column]).present?
        prefix_id = options[:prefix_column] ? self[options[:prefix_column]] : self.sequence_generator_id
        if prefix_id.present?
          sequence = Sequence.find(prefix_id)
          if sequence.scope.to_s == send(options[:scope]).to_s
            assign_attributes(options[:column]=> sequence.generate_sequence_number)
          else
            errors.add(:sequential_id, 'Sequence is not associated with your branch')
          end
        else
          date_to_consider = Time.now
          if options[:date_column] && send(options[:date_column])
            date_to_consider = send(options[:date_column])
          end
          sequence = Sequence.where(purpose: options[:purpose], scope: send(options[:scope]))
                         .where('valid_from <= ? AND valid_till >= ?', date_to_consider, date_to_consider).first
          unless self.as_json[options[:column]].present?
            if sequence
              sequence.lock!
              assign_attributes(options[:column]=> sequence.generate_sequence_number)
            else
              errors.add(:sequential_id, 'Sequence is not created')
            end
          end
        end
      end
    end
  end
end

# ActiveRecord::Base.send(:include, SequenceGenerator::ActsAsSequenced)
