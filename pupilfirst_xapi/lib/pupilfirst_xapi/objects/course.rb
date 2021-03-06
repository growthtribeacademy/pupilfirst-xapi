module PupilfirstXapi
  module Objects
    class Course
      def call(course, uri)
        Builder.new(
          id: uri,
          type: 'http://adlnet.gov/expapi/activities/product',
          name: course.name,
          description: course.description
        ).tap do |obj|
          if course.ends_at.present?
            duration = ActiveSupport::Duration.build(course.ends_at - course.created_at).iso8601
            obj.with_extension("http://id.tincanapi.com/extension/planned-duration", duration)
          end
        end.call
      end
    end
  end
end
