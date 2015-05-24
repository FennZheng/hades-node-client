http = require('http')
url = require('url')
ProjectConfig = require("../project_config").ProjectConfig
Handler = require("./monitor_handler")
Log = require("../log").Log

NOT_FOUND = "404 Not Found, please use urls as follow: \n\n" +
  "\tip:port/monitor\n" +
  "\tip:port/monitor/sysData\n" +
  "\tip:port/monitor/userData/{key}\n"

STATUS = {
	"SUCCESS" : {
		"code" : 2000,
		"msg" : "OK"
	},
	"URL_ILLEGAL" : {
		"code" : 5011,
		"msg" : "Request Url Illegal"
	}
	"ERROR" : {
		"code" : 5000,
		"msg" : "Internel Server Error"
	}
}

init = ->
	_monitorConfig = ProjectConfig.getMonitor()
	return if not _monitorConfig
	_port = _monitorConfig.port || 9881

	return if _monitorConfig.disable
	server = http.createServer(_handlerReq).listen(_port)

	server.on("error", (error)->
		Log.error("monitor server start error code:#{error.code} stack:#{error.stack}")
	)

	server.on("listening", ()->
		Log.info "monitor server started"
	)

_doResp = (resp, statusCode, msg)->
	resp.writeHeader(statusCode, {
		'Content-Length': msg.length,
		'Content-Type': 'text/plain;charset=utf-8'
	})
	resp.end(msg, "utf-8")
	return

# keep name different...
_handlerReq = (req, resp)->
	_data = ""
	_pathname = url.parse(req.url).pathname
	if not _pathname
		return _doResp(resp, STATUS.URL_ILLEGAL.code, STATUS.URL_ILLEGAL.msg)
	_data = Handler.resolve(_pathname)
	if not _data
		_data = NOT_FOUND
	# user data must not be a Error
	if _data instanceof Error
		return _doResp(resp, STATUS.SUCCESS.code, _data.stack?.toString?())
	return _doResp(resp, STATUS.SUCCESS.code, _data)


exports.init = init