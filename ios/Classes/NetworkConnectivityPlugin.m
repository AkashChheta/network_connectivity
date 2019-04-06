#import "NetworkConnectivityPlugin.h"
#import <network_connectivity/network_connectivity-Swift.h>

@implementation NetworkConnectivityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNetworkConnectivityPlugin registerWithRegistrar:registrar];
}
@end
