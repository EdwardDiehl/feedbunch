########################################################
# AngularJS service to load user configuration data in the scope.
########################################################

angular.module('feedbunch').service 'userDataSvc',
['$rootScope', '$http', 'timerFlagSvc', 'quickReadingSvc',
($rootScope, $http, timerFlagSvc, quickReadingSvc)->

  #---------------------------------------------
  # Load user configuration data via AJAX into the root scope
  #---------------------------------------------
  load_data: ->
    $http.get('/user_data.json')
    .success (data)->
      $rootScope.open_all_entries = data["open_all_entries"]
      $rootScope.quick_reading = data["quick_reading"]
      # Start running Quick Reading mode, if the user has selected it.
      quickReadingSvc.start() if $rootScope.quick_reading
    .error (data, status)->
      timerFlagSvc.start 'error_loading_user_data' if status!=0
]