require "active_job"
require 'xapi'

module PupilfirstXapi
  class Outbox
    class Job < ActiveJob::Base
      queue_as :default

      def perform(payload)
        outbox.call(**payload)
      end

      private

      def outbox
        Outbox.new(
          lrs: lrs,
          repository: PupilfirstXapi.repository,
          uri_for: PupilfirstXapi.uri_for
        )
      end

      def remote_lrs
        Xapi.create_remote_lrs(
          end_point: ENV['LRS_ENDPOINT'],
          user_name: ENV['LRS_USERNAME'],
          password: ENV['LRS_PASSWORD']
        )
      end
    end

    class << self
      def <<(payload)
        Outbox::Job.perform_later(payload)
      end
    end

    def initialize(lrs:, repository:, uri_for:)
      @lrs = lrs
      @repository = repository
      @uri_for = uri_for
    end

    def call(**payload)
      Xapi.post_statement(remote_lrs: @lrs, statement: statement_for(**payload))
    end

    private
    attr_reader :lrs, :repository, :uri_for

    def statement_for(id:, event_type:, timestamp:, **args)
      builder_for(event_type).call(**args).tap do |statement|
        statement.stamp(id: id, timestamp: timestamp)
      end
    end

    def builder_for(event_type)
      Statements.builder_for(event_type).new(repository, uri_for)
    end
  end
end
