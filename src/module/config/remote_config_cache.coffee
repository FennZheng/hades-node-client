class RemoteConfigCache
	@_inited = false
	constructor : ->
		@_cache = {}

	init : ->
		if not @_inited
			@_cache = {}
			@_inited = true

	set : (key, value)->
		@_cache[key] = value
		return

	get : (key)->
		@_cache[key]

instance = new RemoteConfigCache()

exports.RemoteConfigCache = instance