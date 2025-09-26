# frozen_string_literal: true

module Nav
  class NavDefaults

    def self.navigation_items
      helpers = ApplicationController.helpers
      routes = Rails.application.routes.url_helpers
      [
        # Left-aligned primary navigation
        Nav::MainItem.new(
          id: 'nav-projects',
          label: I18n.t('layouts.nav.navigation.link_projects_text'),
          url: routes.projects_path,
          position: 1
        ),
        Nav::MainItem.new(
          id: 'nav-downloads',
          label: I18n.t('layouts.nav.navigation.link_downloads_text'),
          url: routes.download_status_path,
          position: 2
        ),
        Nav::MainItem.new(
          id: 'nav-uploads',
          label: I18n.t('layouts.nav.navigation.link_uploads_text'),
          url: routes.upload_status_path,
          position: 3
        ),
        Nav::MainItem.new(
          id: 'repositories',
          label: I18n.t('layouts.nav.navigation.link_repositories_text'),
          items: [
            {
              id: 'nav-dataverse',
              label: I18n.t('layouts.nav.navigation.link_dataverse_text'),
              url: routes.connect_repo_path({ connector_type: ConnectorType::DATAVERSE.to_s, object_type: 'landing' }),
              icon: 'connector://dataverse',
              position: 1
            },
            {
              id: 'nav-zenodo',
              label: I18n.t('layouts.nav.navigation.link_zenodo_text'),
              url: Nav::NavDefaults.zenodo_landing_url,
              icon: 'connector://zenodo',
              position: 2
            },
            {
              id: 'repositories-settings-separator',
              label: '---',
              position: 3
            },
            {
              id: 'nav-repo-settings',
              label: I18n.t('layouts.nav.navigation.link_repo_settings_text'),
              url: routes.repository_settings_path,
              icon: 'bs://bi-gear-fill',
              position: 4
            }
          ],
          position: 4
        ),

        # Right-aligned navigation
        Nav::MainItem.new(
          id: 'nav-ood-dashboard',
          label: 'Open OnDemand',
          url: helpers.ood_dashboard_url,
          alignment: 'right',
          icon: helpers.asset_path('ood_icon.svg'),
          position: 1
        ),
        Nav::MainItem.new(
          id: 'help',
          label: I18n.t('layouts.nav.navigation.link_help_text'),
          alignment: 'right',
          items: [
            {
              id: 'nav-guide',
              label: I18n.t('layouts.nav.navigation.link_guide_text'),
              url: helpers.guide_url,
              new_tab: true,
              icon: 'bs://bi-book',
              position: 1
            },
            {
              id: 'nav-sitemap',
              label: I18n.t('layouts.nav.navigation.link_sitemap_text'),
              url: routes.sitemap_path,
              icon: 'bs://bi-diagram-3',
              position: 2
            },
            {
              id: 'nav-restart',
              label: I18n.t('layouts.nav.navigation.link_restart_text'),
              url: routes.widgets_path('restart'),
              icon: 'bs://bi-bootstrap-reboot',
              position: 3
            },
            {
              id: 'help-reset-separator',
              label: '---',
              position: 4
            },
            {
              id: 'nav-reset',
              label: I18n.t('layouts.nav.navigation.link_reset_text'),
              partial: 'reset_button',
              position: 5
            }
          ],
          position: 2
        )
      ]
    end

    def self.zenodo_landing_url
      default_zenodo_url = Zenodo::ZenodoUrl.default_url

      Rails.application.routes.url_helpers.explore_path(
        connector_type: ConnectorType::ZENODO.to_s,
        server_domain: default_zenodo_url.domain,
        server_scheme: default_zenodo_url.scheme_override,
        server_port: default_zenodo_url.port_override,
        object_type: 'landing',
        object_id: ':root'
      )
    end
  end
end