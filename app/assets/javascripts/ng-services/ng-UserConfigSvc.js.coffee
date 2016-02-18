########################################################
# AngularJS service to load user configuration in the scope.
########################################################

angular.module('feedbunch').service 'userConfigSvc',
['$rootScope', 'timerFlagSvc', 'quickReadingSvc', 'openAllEntriesSvc', 'tourSvc', 'keyboardShortcutsSvc',
($rootScope, timerFlagSvc, quickReadingSvc, openAllEntriesSvc, tourSvc, keyboardShortcutsSvc)->

  # CSRF token
  token = csrfTokenSvc.get_token()

  # Web worker to retrieve user config
  worker = new Worker '<%= asset_path 'workers/load_user_config_worker' %>'
  worker.onmessage = (e) ->
    if e.data.status == 200 || e.data.status == 304
      $rootScope.open_all_entries = e.data.response.open_all_entries
      $rootScope.quick_reading = e.data.response.quick_reading
      $rootScope.show_main_tour = e.data.response.show_main_tour
      $rootScope.show_mobile_tour = e.data.response.show_mobile_tour
      $rootScope.show_feed_tour = e.data.response.show_feed_tour
      $rootScope.show_entry_tour = e.data.response.show_entry_tour
      $rootScope.show_kb_shortcuts_tour = e.data.response.show_kb_shortcuts_tour
      $rootScope.kb_shortcuts_enabled = e.data.response.kb_shortcuts_enabled
      $rootScope.kb_shortcuts = e.data.response.kb_shortcuts

      # Start running Quick Reading mode, if the user has selected it.
      quickReadingSvc.start() if $rootScope.quick_reading

      # Start lazy-loading images, if all entries are open by default
      openAllEntriesSvc.start() if $rootScope.open_all_entries

      # Show application tours if corresponding user config flags are set to true
      tourSvc.start()

      # Initialize responding to keyboard shortcuts (if the user has them enabled in his config)
      keyboardShortcutsSvc.init()
    else if e.data.status == 401 || e.data.status == 422
      $window.location.href = '/login'
    else
      timerFlagSvc.start 'error_loading_user_config'

  service =

    #---------------------------------------------
    # Load user configuration data via AJAX into the root scope
    #---------------------------------------------
    load_config: ->
      worker.postMessage {token: token}

  return service
]