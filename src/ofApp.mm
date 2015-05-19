#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup()
{
    ofSetVerticalSync(true);
    
    undo.addListener(this, &ofApp::undoButtonPressed);
    prn.addListener(this, &ofApp::prnButtonPressed);
    
    ofBackground(0, 0, 0);
    glEnable(GL_DEPTH_TEST);
    cam.setDistance(100.0);
    cam.disableMouseInput();
    
    for (int i = 0; i < GRANURARITY; i++)
    {
        for (int j = 0; j < LAYERS; j++)
        {
            myVerts[j * GRANURARITY + i].set(0, 0, 0);
            myColor[j * GRANURARITY + i].set(0.5, 0.8, 1.0, 1.0);
            radians[j * GRANURARITY + i] = 15.0;
        }
    }
    myVbo.setVertexData(myVerts, NUM_PARTICLES, GL_DYNAMIC_DRAW);
    myVbo.setColorData(myColor, NUM_PARTICLES, GL_DYNAMIC_DRAW);
    
    gui.setup();
    gui.add(spd.setup("spd", 0.005, -0.03, 0.03));
    gui.add(undo.setup("undo", 50.0, 50.0));
    
    prngui.setup();
    gui.add(prn.setup("prn", 50.0, 50.0));
    
    for (int i=0; i<100; i++) {
        myPoints[i].x = 0.0;
        myPoints[i].y = 0.0;
    }
    
    sender.setup(HOST, PORT);
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    float steps = ofGetFrameNum()*spd;
    float maxval = 0.0;
    
    for (int i=0; i<GRANURARITY; i++)
    {
        for (int j=0; j<LAYERS; j++)
        {
            float r = radians[j*GRANURARITY+i];
            float z = (j-LAYERS/2) * THICKNESS;
            myVerts[j*GRANURARITY+i] = ofVec3f(r*cos(steps+i*(2*PI/GRANURARITY)), z, r*sin(steps+i*(2*PI/GRANURARITY)));
            myColor[j*GRANURARITY+i] = ofFloatColor(0.5, 0.8, 1.0, 1.0);
        }
    }
    
    for (int i=0; i<GRANURARITY; i++)
    {
        if (sin(steps+i*(2*PI/GRANURARITY))>maxval) {
            peak = i + 90;
            maxval = sin(steps+i*(2*PI/GRANURARITY));
        }
    }
    
    myVbo.updateVertexData(myVerts, NUM_PARTICLES);
    myVbo.updateColorData(myColor, NUM_PARTICLES);

}

//--------------------------------------------------------------
void ofApp::draw()
{
    
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2, ofGetHeight()/2);
    
    cam.begin();
    glPointSize(2.0);
    glEnable(GL_POINT_SMOOTH);
    myVbo.draw(GL_POINTS, 0, NUM_PARTICLES);
    cam.end();
    
    ofPopMatrix();
    gui.draw();
}

//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    //printf("mX: %d, mY: %d\n", ofGetMouseX(), ofGetMouseY());
    
    if(ofGetMouseY()>125 && ofGetMouseY()<475 && ofGetMouseX()>145 && ofGetMouseX()<175)
    {
        for (int k=0; k<99; k++) {
            myPoints[99-k] = myPoints[99-k-1];
        }
        
        
        layor_n = int(ofMap(ofGetMouseY(), 125.0, 475.0, LAYERS-1, 0.0));
        myPoints[0] = ofVec2f(peak, layor_n);
        
        radians[layor_n*GRANURARITY + peak] -= 2.0;
        radians[layor_n*GRANURARITY + (peak+1)%GRANURARITY] -= 1.5;
        radians[layor_n*GRANURARITY + (peak-1)%GRANURARITY] -= 1.5;
        radians[layor_n*GRANURARITY + (peak-2)%GRANURARITY] -= 0.5;
        radians[layor_n*GRANURARITY + (peak+2)%GRANURARITY] -= 0.5;
        
        if(layor_n<LAYERS-1)
        {
            radians[(layor_n+1)*GRANURARITY + peak%GRANURARITY] -= 1.5;
            radians[(layor_n+1)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.0;
            radians[(layor_n+1)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.0;
            radians[(layor_n+1)*GRANURARITY + (peak+2)%GRANURARITY] -= 0.5;
            radians[(layor_n+1)*GRANURARITY + (peak-2)%GRANURARITY] -= 0.5;
        }
        if(layor_n>0)
        {
            radians[(layor_n-1)*GRANURARITY + peak%GRANURARITY] -= 1.5;
            radians[(layor_n-1)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.0;
            radians[(layor_n-1)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.0;
            radians[(layor_n-1)*GRANURARITY + (peak+2)%GRANURARITY] -= 0.5;
            radians[(layor_n-1)*GRANURARITY + (peak-2)%GRANURARITY] -= 0.5;
        }
        if (layor_n<LAYERS-2) {
            radians[(layor_n+2)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.5;
            radians[(layor_n+2)*GRANURARITY + peak%GRANURARITY] -= 0.5;
            radians[(layor_n+2)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.5;
        }
        if (layor_n>1) {
            radians[(layor_n-2)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.5;
            radians[(layor_n-2)*GRANURARITY + peak%GRANURARITY] -= 0.5;
            radians[(layor_n-2)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.5;
        }
        
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    // printf("mX: %d, mY: %d\n", ofGetMouseX(), ofGetMouseY());
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}

//-----------------------------

void ofApp::undoButtonPressed()
{
    int x = int(myPoints[0].x);
    int y = int(myPoints[0].y);
    if (x==0 && y==0) {
        return;
    }
    
    radians[y*GRANURARITY + x]                         += 2.0;
    radians[y*GRANURARITY + (x+1)%GRANURARITY]         += 1.5;
    radians[y*GRANURARITY + (x-1)%GRANURARITY]         += 1.5;
    radians[y*GRANURARITY + (x-2)%GRANURARITY]         += 0.5;
    radians[y*GRANURARITY + (x+2)%GRANURARITY]         += 0.5;
    
    if(y<LAYERS-1)
    {
        radians[(y+1)*GRANURARITY + x%GRANURARITY]     += 1.5;
        radians[(y+1)*GRANURARITY + (x+1)%GRANURARITY] += 1.0;
        radians[(y+1)*GRANURARITY + (x-1)%GRANURARITY] += 1.0;
        radians[(y+1)*GRANURARITY + (x+2)%GRANURARITY] += 0.5;
        radians[(y+1)*GRANURARITY + (x-2)%GRANURARITY] += 0.5;
    }
    if(y>0)
    {
        radians[(y-1)*GRANURARITY + x%GRANURARITY]     += 1.5;
        radians[(y-1)*GRANURARITY + (x+1)%GRANURARITY] += 1.0;
        radians[(y-1)*GRANURARITY + (x-1)%GRANURARITY] += 1.0;
        radians[(y-1)*GRANURARITY + (x+2)%GRANURARITY] += 0.5;
        radians[(y-1)*GRANURARITY + (x-2)%GRANURARITY] += 0.5;
    }
    if (y<LAYERS-2) {
        radians[(y+2)*GRANURARITY + (x-1)%GRANURARITY] += 0.5;
        radians[(y+2)*GRANURARITY + x%GRANURARITY]     += 0.5;
        radians[(y+2)*GRANURARITY + (x+1)%GRANURARITY] += 0.5;
    }
    if (y>1) {
        radians[(y-2)*GRANURARITY + (x-1)%GRANURARITY] += 0.5;
        radians[(y-2)*GRANURARITY + x%GRANURARITY]     += 0.5;
        radians[(y-2)*GRANURARITY + (x+1)%GRANURARITY] += 0.5;
    }
    
    for(int k=0; k<98; k++)
    {
        myPoints[k] = myPoints[k+1];
    }
    myPoints[99] = ofVec2f(0,0);
    
}



void ofApp::prnButtonPressed()
{
    ofxOscMessage m;
    m.setAddress("/radians");
    for (int s=0; s<NUM_PARTICLES; s++) {
        m.addFloatArg(radians[s]);
    }
    sender.sendMessage(m);
    printf("ll");
}

