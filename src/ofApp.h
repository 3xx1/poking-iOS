#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxGui.h"
#include "ofxOsc.h"


#define GRANURARITY     90
#define LAYERS          60
#define THICKNESS       1
#define NUM_PARTICLES   GRANURARITY * LAYERS
#define NUM_POLYGONS    (LAYERS-1)*(GRANURARITY*2)

#define HOST "69.91.177.7"
#define PORT 12001

class ofApp : public ofxiOSApp {
    
public:
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void undoButtonPressed();
    void prnButtonPressed();
    
    void touchDownEvent(int x, int y);
    void touchMoveEvent(int x, int y);
    
    ofEasyCam cam;
    
    ofVbo myVbo;
    ofVbo wireframeVbo;
    
    ofVec3f myPoints[1000];
    ofVec3f myVerts[NUM_PARTICLES];
    ofVec3f vertsForDraw[NUM_POLYGONS];
    ofFloatColor colorForDraw[NUM_POLYGONS];
    ofFloatColor myColor[NUM_PARTICLES];
        
    float radians[NUM_PARTICLES];
    float speed;
    
    ofxFloatSlider spd;
    ofxButton undo;
    ofxButton prn;
    ofxPanel gui;
    ofxPanel prngui;
    
    ofLight light;
    ofMaterial material;
    
    int layor_n;
    int peak;
    float digDepth;
    
    ofxOscSender sender;
    
};

