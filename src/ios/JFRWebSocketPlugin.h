#import <Cordova/CDV.h>
#import "JFRWebSocket.h"

@interface JFRWebSocketPlugin  : CDVPlugin <JFRWebSocketDelegate>

@property(nonatomic, strong)JFRWebSocket *socket;
@property (strong) NSString* callbackId;
@property (nonatomic, assign) BOOL closing;

-(void) open: (CDVInvokedUrlCommand *) command;
-(void) stop: (CDVInvokedUrlCommand *) command;
-(void) send: (CDVInvokedUrlCommand *) command;

@end
