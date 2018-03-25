# Source: https://github.com/phallstrom/slackistrano/issues/50
#
# TODO rename to SCM::ChangeLog
#
module Capistrano
  class My < ::Capistrano::SCM::Plugin
    def define_tasks
      eval_rakefile File.expand_path("../tasks/set_changelog.rake", __FILE__)
    end

    def register_hooks
      after "deploy:published", "set_changelog"
    end
  end
end
