//
//  myGuiView.h
//  pPad
//
//  Created by Hidekazu Saegusa on 2015/06/09.
//
//

#import <UIKit/UIKit.h>
#include "ofApp.h"

@interface myGuiView : UIViewController
{
    ofApp *myApp;
}

@property (strong, nonatomic) IBOutlet UIImageView *canvas;

-(IBAction)changeSpeed:(id)sender;
-(IBAction)undoButtonPressed:(id)sender;
-(IBAction)doneButtonPressed:(id)sender;

@end
