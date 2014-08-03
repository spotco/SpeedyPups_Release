//
//  main.m
//  cocos2d_test
//
//  Created by spotco on 4/13/14.
//  Copyright spotco 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#ifdef ANDROID
	[UIScreen mainScreen].currentMode =
	[UIScreenMode emulatedMode:UIScreenBestEmulatedMode];
#endif
    int retVal = UIApplicationMain(argc, argv, nil, @"AppController");
    [pool release];
    return retVal;
}
