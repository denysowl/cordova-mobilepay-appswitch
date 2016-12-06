#import "CordovaMobilePayAppSwitch.h"

#import <Cordova/CDVAvailability.h>
#import "MobilePayManager.h"

@implementation CordovaMobilePayAppSwitch

NSString *myCallbackId;

- (void)pluginInitialize {
  NSLog(@"plugin initializing");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}
- (void)finishLaunching:(NSNotification *)notification
{
    // Put here the code that should be on the AppDelegate.m
    // NSString* urlScheme = [self.commandDelegate.settings objectForKey:[@"urlScheme" lowercaseString]];
    // NSLog(@"finshLaunching %@", urlScheme);
    NSLog(@"Finish launching mobile pay plugin");
}
- (void)startPayment:(CDVInvokedUrlCommand *)command {
    NSString* urlScheme = [self.commandDelegate.settings objectForKey:[@"urlScheme" lowercaseString]];
    NSString* merchantId = [self.commandDelegate.settings objectForKey:[@"merchantId" lowercaseString]];

    if (![[MobilePayManager sharedInstance]isMobilePayInstalled:MobilePayCountry_Denmark]) {
      //Another method:
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"MobilePay påkrævet"
                                                                       message:@"For at kunne betale er det nødvendigt at have MobilePay installeret"
                                                                preferredStyle:UIAlertControllerStyleAlert];
      //We add buttons to the alert controller by creating UIAlertActions:
      UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Fortryd"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil]; //You can use a block here to handle a press on this button

      UIAlertAction *actionInstall = [UIAlertAction actionWithTitle:@"Installer"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action) {
                                                NSURL *url = [NSURL URLWithString:[[MobilePayManager sharedInstance] mobilePayAppStoreLinkDK]];
                                                [[UIApplication sharedApplication] openURL:url];
                                              }]; //You can use a block here to handle a press on this button


      [alertController addAction:actionCancel];
      [alertController addAction:actionInstall];

      UIViewController* rootController = [UIApplication sharedApplication].delegate.window.rootViewController;

      [rootController presentViewController:alertController animated:YES completion:nil];
      return;
    }

    NSLog(@"6startPayment, urlScheme: '%@', merchantId: '%@''", urlScheme, merchantId);
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:urlScheme object:nil];
    //NSLog(@"After addObserver: country:'%i'",MobilePayCountry_Denmark);
  [[MobilePayManager sharedInstance] setupWithMerchantId:merchantId merchantUrlScheme:urlScheme country:MobilePayCountry_Denmark];
    //NSLog(@"After setupWithMerchantId");
    //NSLog(@"command:'%@'",command);

    myCallbackId = command.callbackId;
    NSString* amountStr = [command.arguments objectAtIndex:0];
    NSString* orderId = [command.arguments objectAtIndex:1];



    float fAmount = [amountStr floatValue];
    //NSLog(@"convert to float:'%f'",fAmount);
    //NSLog(@"After extract, amount:'%@', order:'%@' float:'%f'",amountStr,orderId,fAmount);

    NSDictionary *jsonResultDict = nil;
    CDVPluginResult *result = nil;


    MobilePayPayment *payment = nil;
    @try{
      payment = [[MobilePayPayment alloc]initWithOrderId:orderId productPrice:fAmount];
    }
    @catch (NSException *exception){
      //NSLog(@"%@", exception.reason);

      jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      @"Error when creating payment", @"errorMessage",
      nil];
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
      [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];
      return;
    }

    /*UIAlertView *startAlert = [[UIAlertView alloc] initWithTitle:@"startAlert"
                                                    message:@"a asfd sd fsd"
                                                  delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Install MobilePay",nil];
    [startAlert show];
    */

    NSLog(@"Created payment");


    /*jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
    @"Test error", @"errorMessage",
    nil];
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
    [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];*/


    /*jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSString stringWithFormat:@"After extract, amount:'%@', order:'%@' float:'%f'",amountStr,orderId,fAmount], @"errorMessage",
    nil];
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
    [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];
    */


        //No need to start a payment if one or more parameters are missing
        if (payment && orderId && ([orderId length] > 0)/* && (fAmount >= 0)*/) {

          jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          @"order and product price ok3", @"errorMessage",
          nil];
          result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
          [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];
          return;
            NSLog(@"order and productprice ok");

            /*UIAlertView *okAlert = [[UIAlertView alloc] initWithTitle:@"okAlert"
                                                            message:@"a asfd sd fsd"
                                                          delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Install MobilePay",nil];
            [okAlert show];*/

            @try{

              [[MobilePayManager sharedInstance]beginMobilePaymentWithPayment:payment error:^(NSError * _Nonnull error) {
                  NSLog(@"error in payment");

                  NSDictionary *jsonResultDict = nil;
                  CDVPluginResult *result = nil;

                  jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
                  @"Error in beginMobilePaymentWithPayment", @"errorMessage",
                  nil];
                  result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
                  [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];


                  /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                                  message:[NSString stringWithFormat:@"reason: %@, suggestion: %@",error.localizedFailureReason, error.localizedRecoverySuggestion]
                                                                delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:@"Install MobilePay",nil];
                  [alert show];*/
              }];
            }
            @catch (NSException *exception){
              jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
              @"Exception in beginMobilePaymentWithPayment", @"errorMessage",
              nil];
              result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
              [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];
              return;

              //NSLog(@"begin: %@", exception.reason);
              /*UIAlertView *exceptionAlert = [[UIAlertView alloc] initWithTitle:@"exceptionAlert"
                                                              message:@"a asfd sd fsd"
                                                            delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Install MobilePay",nil];
              [exceptionAlert show];*/
            }
        } else {
          //NSLog(@"Not ok");

          jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          @"price and orderId not ok", @"errorMessage",
          nil];
          result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
          [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];
          return;
        }

    //for test, sleep to allow logs to be used
    NSLog(@"end");
    /*UIAlertView *endAlert = [[UIAlertView alloc] initWithTitle:@"title2"
                                                    message:@"a asfd sd fsd"
                                                  delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Install MobilePay",nil];
    [endAlert show];*/
}
- (void)handleOpenURL:(NSNotification*)notification
{
    NSURL* url = [notification object];
    NSLog(@"handleOpenUrl called");
    if ([url isKindOfClass:[NSURL class]]) {
        [self handleMobilePayPaymentWithUrl:url];
        NSLog(@"handleOpenURL %@", url);
    }
}

- (void)handleMobilePayPaymentWithUrl:(NSURL *)url
{
    [[MobilePayManager sharedInstance]handleMobilePayPaymentWithUrl:url success:^(MobilePaySuccessfulPayment * _Nullable mobilePaySuccessfulPayment) {
        NSString *orderId = mobilePaySuccessfulPayment.orderId;
        NSString *transactionId = mobilePaySuccessfulPayment.transactionId;
        NSString *amountWithdrawnFromCard = [NSString stringWithFormat:@"%f",mobilePaySuccessfulPayment.amountWithdrawnFromCard];


        NSDictionary *jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        orderId, @"orderId",
        transactionId, @"transactionId",
        amountWithdrawnFromCard, @"amountWithdrawnFromCard",
        nil];

        NSData *jsonResultData = [NSJSONSerialization dataWithJSONObject:jsonResultDict options:NSJSONWritingPrettyPrinted error: nil];
        NSString *jsonResultString = [[NSString alloc] initWithData:jsonResultData encoding:NSUTF8StringEncoding];
        NSLog(@"SuccessResult:\n%@", jsonResultString);

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonResultDict];
        [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];

    } error:^(NSError * _Nonnull error) {
        NSDictionary *dict = error.userInfo;
        NSString *errorMessage = [dict valueForKey:NSLocalizedFailureReasonErrorKey];

        NSDictionary *jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:error.code], @"errorCode",
        errorMessage, @"errorMessage",
        nil];

        NSData *jsonResultData = [NSJSONSerialization dataWithJSONObject:jsonResultDict options:NSJSONWritingPrettyPrinted error: nil];
        NSString *jsonResultString = [[NSString alloc] initWithData:jsonResultData encoding:NSUTF8StringEncoding];
        NSLog(@"ErrorResult:\n%@", jsonResultString);

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
        [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];

        //TODO: show an appropriate error message to the user. Check MobilePayManager.h for a complete description of the error codes

        //An example of using the MobilePayErrorCode enum
        //if (error.code == MobilePayErrorCodeUpdateApp) {
        //    NSLog(@"You must update your MobilePay app");
        //}
    } cancel:^(MobilePayCancelledPayment * _Nullable mobilePayCancelledPayment) {

        NSDictionary *jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"Cancelled", @"errorMessage",
        mobilePayCancelledPayment.orderId, @"orderId",
        nil];

        NSData *jsonResultData = [NSJSONSerialization dataWithJSONObject:jsonResultDict options:NSJSONWritingPrettyPrinted error: nil];
        NSString *jsonResultString = [[NSString alloc] initWithData:jsonResultData encoding:NSUTF8StringEncoding];
        NSLog(@"CancelledResult:\n%@", jsonResultString);

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
        [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];

    }];
}

@end
