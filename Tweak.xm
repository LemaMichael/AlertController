@interface BCBatteryDeviceController {
    NSArray* _sortedDevices; 
}
+(id)sharedInstance;
@end

@interface BCBatteryDevice {
    long long _percentCharge;
    NSString* _name;
    BOOL _lowBattery;
}
@end

%hook UIViewController
- (void)presentViewController:(UIViewController *)viewControllerToPresent
animated:(BOOL)flag
completion:(void (^)(void))completion {
    //: Check if the view controller being presented is of UIAlertController
    if ([viewControllerToPresent isKindOfClass: [UIAlertController class]]) {
        UIAlertController *alertController = (UIAlertController *)viewControllerToPresent;
        
        NSMutableString *message = [NSMutableString new];
        
        //: Create Instance of BCBatteryDeviceController
        BCBatteryDeviceController *deviceController = [%c(BCBatteryDeviceController) sharedInstance];
        NSArray *devices = MSHookIvar<NSArray *>(deviceController, "_sortedDevices");
        
        for (BCBatteryDevice *device in devices) {
            long long deviceCharge = MSHookIvar<long long>(device, "_percentCharge");
            NSString *deviceName = MSHookIvar<NSString *>(device, "_name");
            BOOL isLowBattery = MSHookIvar<BOOL>(device, "_lowBattery");
            /*
            [message appendString: [NSString stringWithFormat: @"%@ : %lld%%\n", deviceName,deviceCharge]];
            [message appendString: [NSString stringWithFormat: @"%s%@", "Is the battery low? ", isLowBattery ? @"Yes" : @"NO"]];*/
            
            [message appendString: [NSString stringWithFormat: @"%@ : %lld%%. %s%@\n", deviceName, deviceCharge, "Is the battery low? ", isLowBattery ? @"Yes" : @"No" ]];

        }
        
        [alertController setMessage: message];
        return %orig(alertController,flag,completion);
    } else {
        //: Don't change anything
        return %orig;
    }
}
%end

