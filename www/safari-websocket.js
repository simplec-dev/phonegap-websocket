
var SafariWebSocket = function(url, onopen, onclose, onerror, onmessage) {
	this.readyState=0;
};

SafariWebSocket.prototype.connect = function(url, onopen, onclose, onerror, onmessage) {
	this.url = url;
	this.onopen = onopen || this.onopen;
	this.onclose = onclose || this.onclose;
	this.onerror = onerror || this.onerror;
	this.onmessage = onmessage || this.onmessage;

    window.addEventListener('SafariWebSocketOpen', this.onopen, false);
    window.addEventListener('SafariWebSocketClose', this.onclose, false);
    window.addEventListener('SafariWebSocketMessage', this.onmessage, false);
    window.addEventListener('SafariWebSocketError', this.onerror, false);
	// open the socket
    cordova.exec(this.onMessageReceived, this.onErrorReceived, "SafariWebSocket", "open", [this.url]);
	this.readyState=1;
};
SafariWebSocket.prototype.onMessageReceived = function(data) {
	var t = data.type;

	if (t=="open") {
		var evt = {type: "open"};
        cordova.fireWindowEvent("SafariWebSocketOpen", evt);
	}
	if (t=="closed") {
		var evt = {type: "close"};
        cordova.fireWindowEvent("SafariWebSocketClose", evt);
	}
	if (t=="message") {
		if (data.dataType=="string") {
			var evt = {type: "message", data: data.data};
	        cordova.fireWindowEvent("SafariWebSocketMessage", evt);
		}
	}
	if (t=="error") {
		var evt = {type: "error", message: data.message};
        cordova.fireWindowEvent("SafariWebSocketError", evt);
	}
};
SafariWebSocket.prototype.onErrorReceived = function(data) {
	console.log(data);
	this.readyState=0;
};

SafariWebSocket.prototype.close = function() {
	// close socket
	this.readyState=0;
    cordova.exec(null, null, "SafariWebSocket", "stop", []);
};

SafariWebSocket.prototype.send = function(data) {
	if (!data) return;
	
	if (typeof data === 'string' || data instanceof String) {
	    cordova.exec(null, null, "SafariWebSocket", "send", ["string", data]);
	} else if (data instanceof Blob) {
		var base64data = null;
	    
	    var reader = new window.FileReader();
	    reader.onloadend = function() {
	    	var base64data = reader.result;     
	    	if (base64data) {
	    		if (base64data.indexOf(",")>=0) {
		    		base64data = base64data.substring(base64data.indexOf(",")+1);
	    		}
			    cordova.exec(null, null, "SafariWebSocket", "send", ["blob", base64data]);
	    	}
	    };
	    reader.readAsDataURL(data); 
	}
};
SafariWebSocket.prototype.onopen = function(evt) {
};
SafariWebSocket.prototype.onclose = function(evt) {
};
SafariWebSocket.prototype.onerror = function(evt) {
};
SafariWebSocket.prototype.onmessage = function(evt) {
};

SafariWebSocket.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.websocket = new SafariWebSocket();
  return window.plugins.websocket;
};

cordova.addConstructor(SafariWebSocket.install);