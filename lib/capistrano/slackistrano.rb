# Основной файл настройки slackistrano
#
module Slackistrano
  class CustomMessaging < Messaging::Base
    def payload_for_updating
      {
        text: "#{deployer} разворачивает ветку #{branch} у #{application} на #{stage}"
      }
    end

    # Fancy updated message.
    # See https://api.slack.com/docs/message-attachments
    def payload_for_updated
      changelog = fetch(:changelog)

      changelog = changelog.gsub(/\(#(\d+)\)/, "(<%{repo_url}/pull/%{pr}|#%{pr}>)" % {repo_url: fetch(:repo_url), pr: '\1'}) unless changelog.to_s.empty?

      revision_link = "#{fetch(:repo_url)}/compare/#{fetch(:previous_revision)}...#{fetch(:current_revision)}"

      revision_link = revision_link.gsub('git@github.com:', 'https://github.com/').gsub('.git/','/')

      data = {
        attachments: [{
          color: 'good',
          author_name: deployer,
          title_link: "https://#{application}",
          pretext: "Успешно завершено развертывание #{application} на #{stage}",
          fields: [
            {
              title: 'Изменения',
              value: changelog || 'неизвестны'
            }
          ],

          footer: "<#{revision_link}|Смотреть изменения на github.com>",

          thumb_url: fetch(:slackistrano_thumb_url),
          footer_icon: fetch(:slackistrano_footer_icon),
          fallback: super[:text]
        }]
      }

      data
    end

    # Slightly tweaked failed message.
    # See https://api.slack.com/docs/message-formatting
    def payload_for_failed
      payload = super
      payload[:text] = ":fire: Атака захлебнулась: #{payload[:text]}"
      payload
    end

    # Override the deployer helper to pull the best name available (git, password file, env vars).
    # See https://github.com/phallstrom/slackistrano/blob/master/lib/slackistrano/messaging/helpers.rb
    def deployer
      name = `git config github.user`.strip
      name = nil if name.empty?
      name ||= Etc.getpwnam(ENV['USER']).gecos || ENV['USER'] || ENV['USERNAME']
      "@#{name}"
    end
  end
end
