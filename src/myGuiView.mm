//
//  myGuiView.mm
//  pPad
//
//  Created by Hidekazu Saegusa on 2015/06/09.
//
//

#import "myGuiView.h"

@implementation myGuiView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    myApp = (ofApp*)ofGetAppPtr();
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [[touches anyObject] locationInView:self.canvas];
    myApp->touchDownEvent(currentPoint.x, currentPoint.y);
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [[touches anyObject] locationInView:self.canvas];
    myApp->touchMoveEvent(currentPoint.x, currentPoint.y);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)changeSpeed:(id)sender
{
    UISlider *slider = sender;
    myApp->speed = [slider value];
}

- (IBAction)undoButtonPressed:(id)sender
{
    myApp->undoButtonPressed();
}

- (IBAction)doneButtonPressed:(id)sender
{
    myApp->prnButtonPressed();
}

@end
