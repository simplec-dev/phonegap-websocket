
var SafariWebSocket = function(url, onopen, onclose, onerror, onmessage) {
	this.connect(url, onopen, onclose, onerror, onmessage);
};

SafariWebSocket.prototype.connect = function(url, onopen, onclose, onerror, onmessage) {
	this.url = url;
	this.onopen = onopen || this.onopen;
	this.onclose = onclose || this.onclose;
	this.onerror = onerror || this.onerror;
	this.onmessage = onmessage || this.onmessage;
	
	// open the socket
    exec(this.onMessageReceived, this.onErrorReceived, "SafariWebSocket", "open", [this.url]);
};

SafariWebSocket.prototype.close = function() {
	// close socket
    exec(null, null, "SafariWebSocket", "close", []);
};

SafariWebSocket.prototype.send = function(data) {
	if (!data) return;
	
	if (typeof data === 'string' || data instanceof String) {
	    exec(null, null, "SafariWebSocket", "send", ["string", data]);
	} else if (data instanceof Blob) {
		var base64data = null;
	    
	    var reader = new window.FileReader();
	    reader.onloadend = function() {
	    	var base64data = reader.result;     
	    	if (base64data) {
	    		if (base64data.indexOf(",")>=0) {
		    		base64data = base64data.substring(base64data.indexOf(",")+1);
	    		}
		    	console.log(base64data);
			    exec(null, null, "SafariWebSocket", "send", ["blob", base64data]);
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

//module.exports = new SafariWebSocket();