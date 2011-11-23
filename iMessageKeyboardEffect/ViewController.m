//
//  ViewController.m
//  iMessageKeyboardEffect
//
//  Created by orta therox on 16/10/2011.
//  Copyright (c) 2011 ortatherox.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (private)
- (void)animateKeyboardReturnToOriginalPosition;
- (void)animateKeyboardOffscreen;
@end

static float FingerGrabHandleSize = 20.0f;

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    // always know which keyboard is selected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldWasSelected:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    
    // register for when a keyboard pops up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)textfieldWasSelected:(NSNotification *)notification {
    textField = notification.object;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // To remove the animation for the keyboard dropping showing
    // we have to hide the keyboard, and on will show we set it back.
    keyboard.hidden = NO;
}


- (void)keyboardDidShow:(NSNotification *)notification {
    if(keyboard) return;
    
    //Because we cant get access to the UIKeyboard throught the SDK we will just use UIView. 
    //UIKeyboard is a subclass of UIView anyways
    //see discussion http://www.iphonedevsdk.com/forum/iphone-sdk-development/6573-howto-customize-uikeyboard.html
    
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    for(int i = 0; i < [tempWindow.subviews count]; i++) {
        UIView *possibleKeyboard = [tempWindow.subviews objectAtIndex:i];
        if([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES){
            keyboard = possibleKeyboard;
            return;
        }
    }
}

-(void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:[self view]];  
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        originalKeyboardY = keyboard.frame.origin.y;
    }
    
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){    
        if (velocity.y > 0) {
            [self animateKeyboardOffscreen];
        }else{
            [self animateKeyboardReturnToOriginalPosition];
        }
        return;
    }
        
    CGFloat spaceAboveKeyboard = self.view.bounds.size.height - (keyboard.frame.size.height + textField.frame.size.height) + FingerGrabHandleSize;
    if (location.y < spaceAboveKeyboard) {
        return;
    }
    
    CGRect newFrame = keyboard.frame;
    CGFloat newY = originalKeyboardY + (location.y - spaceAboveKeyboard);
    newY = MAX(newY, originalKeyboardY);
    newFrame.origin.y = newY;
    [keyboard setFrame: newFrame];
}

- (void)animateKeyboardOffscreen {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect newFrame = keyboard.frame;
                         newFrame.origin.y = keyboard.window.frame.size.height;
                         [keyboard setFrame: newFrame];
                     }
     
                     completion:^(BOOL finished){
                         keyboard.hidden = YES;
                         [textField resignFirstResponder];
                     }];
}

- (void)animateKeyboardReturnToOriginalPosition {
    [UIView beginAnimations:nil context:NULL];
    CGRect newFrame = keyboard.frame;
    newFrame.origin.y = originalKeyboardY;
    [keyboard setFrame: newFrame];
    [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
