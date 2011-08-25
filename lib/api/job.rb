module Hudson
  class Job < HudsonBase

    attr_reader :msg, :hudson_url

    def initialize(jobname)
      @jobname = jobname
      @api_suffix = "/api/json"
      @module_url = "/job/"
      load
    end

    # Return status of job
    def heathStatusDescription
      desc = String.new
      @msg.fetch("healthReport").each do |report|
        desc += report.fetch("description")
      end
      return desc
    end

    # Return the las complete build
    # as a JobInstance
    def lastCompletedBuild
      id = @msg.fetch("lastCompletedBuild").fetch("number")
      JobInstance.new(@jobname, id)
    end

    # Return builds from this job
    def builds
      @msg.fetch("builds")
    end

    # Create a new hudson job
    def self.create(jobname, config)
      url = "#{Hudson[:url]}/createItem?name=#{jobname}"
      send_xml_post_request(url, config)
    end

    # Update a hudson job
    def self.update(jobname, config)
      url = "#{Hudson[:url]}/job/#{jobname}/config.xml"
      send_xml_post_request(url, config)
    end

    # Perform a build
    def self.run(jobname)
      url = "#{Hudson[:url]}/job/#{jobname}/build"
      send_post_request(url)
    end


    private
    def load
      url = "#{Hudson[:url]}/#{@module_url}/#{@jobname}/#{Hudson[:api_suffix]}"
      puts url
      resp = Net::HTTP.get_response(URI.parse(url))
      data = resp.body
      result = JSON.parse(data)
      @msg = result
    end
  end
end
