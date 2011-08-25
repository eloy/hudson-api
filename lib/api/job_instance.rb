module Hudson

  class JobInstance
    attr_reader :msg, :jobname, :id

    def initialize(jobname, id)
      @jobname = jobname
      @id = id
      @module_url = "/job/"
      load
    end

    # return artifacts created in this instance
    def artifacts
      f("artifacts")
    end

    def changeset
      f("changeSet")
    end

    def building?
      f("building")
    end

    def duration
      f("duration")
    end

    def number
      f("number")
    end

    def result
      f("result")
    end

    def timestamp
      f("timestamp")
    end
    private

    def f(p)
      @msg.fetch(p)
    end

    def load
      url = "#{Hudson[:url]}/#{@module_url}/#{@jobname}/#{@id}/#{Hudson[:api_suffix]}"
      puts url
      resp = Net::HTTP.get_response(URI.parse(url))
      data = resp.body
      result = JSON.parse(data)
      @msg = result
    end
  end

end
