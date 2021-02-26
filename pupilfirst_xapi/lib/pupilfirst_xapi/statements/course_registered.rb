module PupilfirstXapi
  module Statements
    class CourseRegistered
      def initialize(repository, uri_for)
        @repository = repository
        @uri_for = uri_for
      end

      def call(actor_id:, resource_id:)
        actor = @repository.call(:user, actor_id)
        course = @repository.call(:course, resource_id)

        Xapi.create_statement(
          actor: Actors.agent(actor),
          verb: Verbs::REGISTERED,
          object: Objects.course(course, @uri_for.call(course))
        )
      end
    end
  end
end
