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

#define HOST "172.20.10.7"
#define PORT 12345

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
    
    ofEasyCam cam;
    ofVbo myVbo;
    ofVec2f myPoints[100];
    ofVec3f myVerts[NUM_PARTICLES];
    ofFloatColor myColor[NUM_PARTICLES];
    
    float radians[NUM_PARTICLES];
    ofxFloatSlider spd;
    ofxButton undo;
    ofxButton prn;
    ofxPanel gui;
    ofxPanel prngui;
    
    int layor_n;
    int peak;
    
    ofxOscSender sender;
};

