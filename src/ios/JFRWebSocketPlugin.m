#import "JFRWebSocket.h"
#import "JFRWebSocketPlugin.h"
#import "Base64.h"
#import <cordova/CDV.h>

@implementation JFRWebSocketPlugin : CDVPlugin

- (void)open:(CDVInvokedUrlCommand*)command
{
    if ([command.arguments count] < 1) {
        // Triggering parameter error
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus : CDVCommandStatus_ERROR
                                   messageAsString  : @"Missing arguments when calling 'open' action."];
        
        [self.commandDelegate
            sendPluginResult : result
            callbackId : command.callbackId
         ];
    }  else {
    	if (self.callbackId) {
            NSLog(@"closing socket");
        	[self setClosing:YES];
            [self.socket disconnect];
            NSLog(@"closed socket");

            if (self.callbackId) {
                NSDictionary* eventData = [NSDictionary dictionaryWithObject:[NSString stringWithString:@"closed"] forKey:@"type"];

                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:eventData];
                [result setKeepCallbackAsBool:NO];
                [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];

            	[self setClosing:NO];
            }
            self.callbackId = nil;
            self.socket = nil;
    	}

    	[self setClosing:NO];
        self.callbackId = command.callbackId;
    	NSString* url = [command.arguments objectAtIndex : 0];
    	NSMutableArray *protocols = [NSMutableArray array];
        self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:url] protocols:protocols];
        self.socket.delegate = self;
        [self.socket connect];
    }
}

- (void)stop:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSLog(@"closing socket");
    	[self setClosing:YES];
        [self.socket disconnect];
        NSLog(@"closed socket");

        if (self.callbackId) {
            NSDictionary* eventData = [NSDictionary dictionaryWithObject:[NSString stringWithString:@"closed"] forKey:@"type"];

            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:eventData];
            [result setKeepCallbackAsBool:NO];
            [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];

        	[self setClosing:NO];
        }
        self.callbackId = nil;
        self.socket = nil;
    }];
}

- (void) send: (CDVInvokedUrlCommand *) command {
    // Validating parameters
    if ([command.arguments count] < 2) {
        // Triggering parameter error
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus : CDVCommandStatus_ERROR
                                   messageAsString  : @"Missing arguments when calling 'send' action."];
        
        [self.commandDelegate
            sendPluginResult : result
            callbackId:command.callbackId
         ];
    } else {
    	NSString* dataType = [command.arguments objectAtIndex : 0];
    	NSString* dataStr = [command.arguments objectAtIndex : 1];

    	if ([dataType isEqualToString:@"string"]) {
    		if (dataStr) {
    	    	[self.socket writeString:dataStr];
    		}
    	}
    	if ([dataType isEqualToString:@"blob"]) {
    	    NSData *data = [NSData dataWithBase64EncodedString:dataStr];
    	    if (data) {
    	    	[self.socket writeData:data];
    	    }
    	}
    }
}

-(void)websocketDidConnect:(JFRWebSocket*)socket {
    NSLog(@"websocket is connected");
    NSDictionary* eventData = [NSDictionary dictionaryWithObject:[NSString stringWithString:@"open"] forKey:@"type"];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:eventData];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
	if ([self closing] && self.socket) {
	    NSLog(@"websocket is disconnected: %@", [error localizedDescription]);
	    NSMutableDictionary *eventData = [[NSMutableDictionary alloc]init];
	    [eventData setValue:[error localizedDescription] forKey:@"message"];
	    [eventData setValue:@"error" forKey:@"type"];

	    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:eventData];
	    [result setKeepCallbackAsBool:NO];
	    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];

        [self.socket disconnect];
        self.callbackId = nil;
        self.socket = nil;
	}
}

-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    NSLog(@"Received text: %@", string);

    NSMutableDictionary *eventData = [[NSMutableDictionary alloc]init];
    [eventData setValue:string forKey:@"data"];
    [eventData setValue:@"string" forKey:@"dataType"];
    [eventData setValue:@"message" forKey:@"type"];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:eventData];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data {
    NSLog(@"Received data: %@", data);
    NSString *dataStr = [data base64EncodedString];

    NSMutableDictionary *eventData = [[NSMutableDictionary alloc]init];
    [eventData setValue:dataStr forKey:@"data"];
    [eventData setValue:@"string" forKey:@"dataType"];
    [eventData setValue:@"message" forKey:@"type"];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:eventData];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)dealloc
{
    [self stop:nil];
}

@end
