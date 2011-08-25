module Hudson
  class JobConfig
    require 'builder'

    attr_accessor :config, :description, :provider, :repositories, :targets, :archived_resources, :disabled

    def initialize
      @disabled = false
      @targets = []
      @provider = "svn"
    end

     def create
      b = Builder::XmlMarkup.new(:indent => 1)
       @config= b.project do |p|
        p.description @description
        p.disabled @disabled

        # Repositories
        unless @repositories.nil?
          if @provider == "svn"
            create_svn(p)
          end

        end

        # Builders
        if @targets.length > 0
          create_builders(p)
        else
          p.builders
        end

        # Create publisers
        create_publisher(p)

        # defaults
        p.properties do |prop|
          prop.tag!("watched-dependencies-property")
        end
        p.actions
        p.keepDependencies false
        p.advancedAffinityChooser false
        p.canRoam true
        p.blockBuildWhenDownstreamBuilding false
        p.blockBuildWhenUpstreamBuilding false
        p.triggers("class"=>"vector")
        p.concurrentBuild false
        p.cleanWorkspaceRequired true
        p.buildWrappers
      end
       @config
    end

    def create_svn(p)
      p.scm("class"=>"hudson.scm.SubversionSCM") do |svn|
        svn.excludedRegions
        svn.includedRegions
        svn.excludedUsers
        svn.excludedRevprop
        svn.excludedCommitMessages
        svn.workspaceUpdater("class"=>"hudson.scm.subversion.UpdateUpdater")

        svn.locations do |l|
          @repositories.each do |repo|
            l.tag!("hudson.scm.SubversionSCM_-ModuleLocation") do |ml|
              ml.remote repo["uri"]
              ml.local repo["path"]
              ml.depthOption "infinity"
              ml.ignoreExternalsOption false
            end
          end
        end
      end
    end

    def create_builders(project)

      shell = "#Prepare project\n"
      buckminster = "import '${WORKSPACE}/feature.p2.site/site.cquery'\n"
      buckminster += "build\n"
      buckminster += "perform -D target.os=* -D target.ws=* -D target.arch=* feature.p2.site#site.p2\n"


      @targets.each do |t|
        shell +=  "/opt/hudson-osx/tools/prepare ${WORKSPACE} #{t["feature"]}\n"
      end

      project.builders do |builder|
        # Shell tashs
        builder.tag!("hudson.tasks.Shell") do |t|
          t.command shell
        end
        # Buckminster task
        builder.tag!("hudson.plugins.buckminster.EclipseBuckminsterBuilder") do |b|
          b.installationName "Buckminster"
          b.commands buckminster
          b.targetPlatformName "Opensixen Core"
          b.logLevel "info"
          b.params
          b.userTemp
          b.userOutput
          b.userCommand
          b.userWorkspace
          b.globalPropertiesFile
          b.equinoxLauncherArgs
        end
      end
    end

    def create_publisher(project)
      project.publishers do |publisher|
        publisher.tag!("hudson.tasks.ArtifactArchiver") do |a|
          a.artifacts @archived_resources
          a.compressionType "GZIP"
          a.latestOnly false
          a.autoValidateFileMask false
        end
      end
    end

  end
end
