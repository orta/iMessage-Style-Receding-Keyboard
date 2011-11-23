//
//  ViewController.m
//  iMessageKeyboardEffect
//
//  Created by orta therox on 16/10/2011.
//  Copyright (c) 2011 ortatherox.com. All rights reserved.
//

#import "ViewController.h"

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
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        originalKeyboardY = keyboard.frame.origin.y;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:[self view]];  
    
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){    
        
        if (translation.y > ((keyboard.frame.size.height / 3) * 2) ) {
            // if the keyboard is over 2/3rds of the way down, 
            // hide it offscreen
            
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
        }else{
            // if the keyboard is in the top third, move 
            // back up to the top.
            
            [UIView beginAnimations:nil context:NULL];
            CGRect newFrame = keyboard.frame;
            newFrame.origin.y = originalKeyboardY;
            [keyboard setFrame: newFrame];
            [UIView commitAnimations];
        }
        
        return;
    }
    
    // Drag vertically with finger. Being sure not to
    // go above the original point.
    CGRect newFrame = keyboard.frame;
    CGFloat newY = originalKeyboardY + translation.y;
    newY = MAX(newY, originalKeyboardY);
    newFrame.origin.y = newY;
    [keyboard setFrame: newFrame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
