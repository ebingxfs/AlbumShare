//
//  AppDelegate.m
//  AlbumShareDemo
//
//  Created by Zzzz on 2019/8/29.
//  Copyright © 2019 Zzzz. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    [self openAppWithUrl:url delay:1.0];
    return YES;
}

- (void)openAppWithUrl:(NSURL *)url delay:(int64_t)delay {
    NSArray *tempArray = [[url absoluteString] componentsSeparatedByString:@"://"];
    NSString *url_string = tempArray[1];
    if ([url_string hasPrefix:@"saveFilePath"]) {
        
        //获取共享的UserDefaults
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:[NSString stringWithFormat:@"group.%@.ShareExtention",bundleIdentifier]];
        
        if ([userDefaults boolForKey:@"newShare"]){
            
            NSArray *imagesDataArray = [userDefaults valueForKey:@"shareImageDataArray"];
            
            NSMutableDictionary *dic = [[imagesDataArray firstObject] mutableCopy];
            NSString *fileUrl = dic[@"fileUrl"];
            
            if (fileUrl) {
                NSError *error;
                //其中NSDataReadingOptions可以附加一个参数NSDataReadingMappedIfSafe参数。使用这个参数后，iOS就不会把整个文件全部读取的内存了，而是将文件映射到进程的地址空间中，这么做并不会占用实际内存。这样就可以解决内存满的问题 https://www.jianshu.com/p/da10690811e5
                NSData *data = [NSData dataWithContentsOfFile:fileUrl options:NSDataReadingMappedIfSafe error:&error];
                
                NSLog(@"%@",@(data.length));
            } else {
                shareDataArray = imagesDataArray;
            }
            
            //重置分享标识
            [userDefaults setBool:NO forKey:@"newShare"];
            [userDefaults removeObjectForKey:@"shareImageDataArray"];
            
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
            });
        }
        
    }
}

static NSArray *shareDataArray = nil;


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
