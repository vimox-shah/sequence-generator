module SequenceGenerator
  class BaseSerializer < ActiveModel::Serializer

    attributes :id, :created_at, :updated_at

    def id
      object.id.to_s if object.id.present?
    end

    def created_at
      object.created_at.to_i if object.created_at
    end

    def updated_at
      object.updated_at.to_i if object.updated_at
    end

  end
end
