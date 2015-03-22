// Generated by CoffeeScript 1.3.3
(function() {
  var ConfigProxy, IConfig, LocalConfig, Module, RemoteConfig,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Module = require('../../lib/Module').Module;

  IConfig = require('./IConfig').IConfig;

  LocalConfig = require('./LocalConfig').LocalConfig;

  RemoteConfig = require('./RemoteConfig').RemoteConfig;

  ConfigProxy = (function(_super) {

    __extends(ConfigProxy, _super);

    function ConfigProxy() {
      return ConfigProxy.__super__.constructor.apply(this, arguments);
    }

    ConfigProxy.prototype.get = function(name) {
      var _val;
      _val = LocalConfig.get(name);
      if (!(_val != null)) {
        _val = RemoteConfig.get(name);
      }
      return _val;
    };

    ConfigProxy.prototype.getDynamic = function(name) {
      var _val;
      _val = LocalConfig.getDynamic(name);
      if (!(_val != null)) {
        _val = RemoteConfig.getDynamic(name);
      }
      return _val;
    };

    return ConfigProxy;

  })(Module);

}).call(this);
