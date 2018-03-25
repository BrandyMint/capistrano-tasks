# Source: https://github.com/phallstrom/slackistrano/issues/50
# TODO Проверить как себя ведет при первом деплое
#
task :set_changelog do
  on release_roles(:all) do
    range = "#{fetch(:previous_revision)}..#{fetch(:current_revision)}"
    within repo_path do
      changelog = capture(:git, 'log', '--oneline', range).force_encoding(Encoding::UTF_8)
      changelog = "No changes between revisions #{range}" if changelog.empty?

      set :changelog, changelog
     end
  end
end
