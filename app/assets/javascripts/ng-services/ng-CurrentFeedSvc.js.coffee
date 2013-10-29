########################################################
# AngularJS service to set, unset and recover the currently selected feed in the root scope
########################################################

angular.module('feedbunch').service 'currentFeedSvc',
['$rootScope', 'entriesPaginationSvc', 'feedsFoldersSvc',
($rootScope, entriesPaginationSvc, feedsFoldersSvc)->

  set: (feed)->
    entriesPaginationSvc.reset_entries()
    $rootScope.current_folder = null
    $rootScope.current_feed = feed
    feedsFoldersSvc.remove_read_feeds()

  unset: ->
    entriesPaginationSvc.reset_entries()
    $rootScope.current_feed = null

  get: ->
    $rootScope.current_feed
]