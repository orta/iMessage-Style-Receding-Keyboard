//
//  ViewController.h
//  iMessageKeyboardEffect
//
//  Created by orta therox on 16/10/2011.
//  Copyright (c) 2011 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIGestureRecognizerDelegate>{
    UIView* keyboard;
    UITextField* textField;
    int originalKeyboardY;
    int originalLocation;
}

@end
