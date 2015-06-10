#include "ofApp.h"
#include "myGuiView.h"

myGuiView *myGuiViewController;

//--------------------------------------------------------------
void ofApp::setup()
{
    ofSetVerticalSync(true);
    
    undo.addListener(this, &ofApp::undoButtonPressed);
    prn.addListener(this, &ofApp::prnButtonPressed);
    
    ofBackground(0, 0, 0);
    ofEnableDepthTest();
    ofEnableSmoothing();
    glEnable(GL_DEPTH_TEST);
    cam.setDistance(100.0);
    cam.disableMouseInput();
    
    
    light.enable();
    light.setSpotlight();
    light.setPosition(-100.0, 100.0, 100.0);
    light.setAmbientColor(ofFloatColor(0.1, 0.1, 0.1, 1.0));
    light.setDiffuseColor(ofFloatColor(0.5, 0.5, 0.5));
    light.setSpecularColor(ofFloatColor(1.0, 1.0, 1.0));
    
    material.setShininess(120);
    material.setSpecularColor(ofColor(255,255,255,255));
    
    speed = 0.01;
    
    for (int i = 0; i < GRANURARITY; i++)
    {
        for (int j = 0; j < LAYERS; j++)
        {
            myVerts[j * GRANURARITY + i].set(0, 0, 0);
            myColor[j * GRANURARITY + i].set(0.5, 0.8, 0.8, 0.1);
            radians[j * GRANURARITY + i] = 15.0;
        }
    }
    
    for (int j=0; j<LAYERS-1; j++)
    {
        for (int i=0; i<GRANURARITY; i++)
        {
            vertsForDraw[j*2*GRANURARITY+i*2].set(0,0,0);
            vertsForDraw[j*2*GRANURARITY+i*2+1].set(0,0,0);
            colorForDraw[j*2*GRANURARITY+i*2].set(1.0, 1.0, 1.0, 0.5);
            colorForDraw[j*2*GRANURARITY+i*2+1].set(1.0, 1.0, 1.0, 0.5);
        }
    }
    
    myVbo.setVertexData(vertsForDraw, NUM_POLYGONS, GL_DYNAMIC_DRAW);
    myVbo.setColorData(colorForDraw, NUM_POLYGONS, GL_DYNAMIC_DRAW);
    wireframeVbo.setVertexData(vertsForDraw, NUM_POLYGONS, GL_DYNAMIC_DRAW);
    wireframeVbo.setColorData(colorForDraw, NUM_POLYGONS, GL_DYNAMIC_DRAW);
    
    
    gui.setup();
    gui.add(spd.setup("spd", 0.005, 0.0, 0.03));
    gui.add(undo.setup("undo", 50.0, 50.0));
    
    prngui.setup();
    gui.add(prn.setup("prn", 50.0, 50.0));
    
    for (int i=0; i<1000; i++) {
        myPoints[i].x = 0.0;
        myPoints[i].y = 0.0;
        myPoints[i].z = 0.0;
    }
    
    sender.setup(HOST, PORT);
    
    // iOS UI Logistics
    
    // iOS UI Logistics
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    if (ofGetFrameNum()==0) {
        myGuiViewController = [[myGuiView alloc] initWithNibName:@"myGuiView" bundle:nil];
        [ofxiPhoneGetUIWindow() addSubview:myGuiViewController.view];
    }
    
    float steps = ofGetFrameNum()*speed;
    float maxval = 0.0;
    digDepth = 1.0;
    
    for (int i=0; i<GRANURARITY; i++)
    {
        for (int j=0; j<LAYERS; j++)
        {
            float r = radians[j*GRANURARITY+i];
            float z = (j-LAYERS/2) * THICKNESS;
            myVerts[j*GRANURARITY+i] = ofVec3f(r*cos(steps+i*(2*PI/GRANURARITY)), z, r*sin(steps+i*(2*PI/GRANURARITY)));
            myColor[j*GRANURARITY+i] = ofFloatColor(0.4, 0.4, ofMap(r, 0.0, 15.0, 0.1, 0.4), 0.5);
        }
    }
    
    for (int j=0; j<LAYERS-1; j++)
    {
        for (int i=0; i<GRANURARITY; i++)
        {
            vertsForDraw[j*2*GRANURARITY+i*2]   = myVerts[j*GRANURARITY+i];
            vertsForDraw[j*2*GRANURARITY+i*2+1] = myVerts[(j+1)*GRANURARITY+i];
            colorForDraw[j*2*GRANURARITY+i*2]   = myColor[j*GRANURARITY+i];
            colorForDraw[j*2*GRANURARITY+i*2+1] = myColor[(j+1)*GRANURARITY+i];
        }
    }
    
    for (int i=0; i<GRANURARITY; i++)
    {
        if (sin(steps+i*(2*PI/GRANURARITY))>maxval) {
            peak = i + 90;
            maxval = sin(steps+i*(2*PI/GRANURARITY));
        }
    }
    
    myVbo.updateVertexData(vertsForDraw, NUM_POLYGONS);
    myVbo.updateColorData(colorForDraw, NUM_POLYGONS);
    wireframeVbo.updateVertexData(vertsForDraw, NUM_POLYGONS);

}

//--------------------------------------------------------------
void ofApp::draw()
{
    
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2, ofGetHeight()/2);
    
    cam.begin();
    glPointSize(2.0);
    glEnable(GL_POINT_SMOOTH);
    
    wireframeVbo.draw(GL_LINE_STRIP, 0, NUM_POLYGONS);
    myVbo.draw(GL_TRIANGLE_STRIP, 0, NUM_POLYGONS);
    cam.end();
    
    ofPopMatrix();
    // gui.draw();
    
    
}

//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    //printf("mX: %d, mY: %d\n", ofGetMouseX(), ofGetMouseY());
    
    if(ofGetMouseY()>125 && ofGetMouseY()<475 && ofGetMouseX()>135 && ofGetMouseX()<185)
    {
        for (int k=0; k<999; k++) {
            myPoints[999-k] = myPoints[999-k-1];
        }
        
        
        layor_n = int(ofMap(ofGetMouseY(), 125.0, 475.0, LAYERS-1, 0.0));
        myPoints[0] = ofVec3f(peak, layor_n, 0.0);
        
        radians[layor_n*GRANURARITY + peak] -= 2.0;
        radians[layor_n*GRANURARITY + (peak+1)%GRANURARITY] -= 1.8;
        radians[layor_n*GRANURARITY + (peak-1)%GRANURARITY] -= 1.8;
        radians[layor_n*GRANURARITY + (peak-2)%GRANURARITY] -= 1.0;
        radians[layor_n*GRANURARITY + (peak+2)%GRANURARITY] -= 1.0;
        
        if(layor_n<LAYERS-1)
        {
            radians[(layor_n+1)*GRANURARITY + peak%GRANURARITY] -= 1.8;
            radians[(layor_n+1)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.5;
            radians[(layor_n+1)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.5;
            radians[(layor_n+1)*GRANURARITY + (peak+2)%GRANURARITY] -= 1.0;
            radians[(layor_n+1)*GRANURARITY + (peak-2)%GRANURARITY] -= 1.0;
        }
        if(layor_n>0)
        {
            radians[(layor_n-1)*GRANURARITY + peak%GRANURARITY] -= 1.8;
            radians[(layor_n-1)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.0;
            radians[(layor_n-1)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.0;
            radians[(layor_n-1)*GRANURARITY + (peak+2)%GRANURARITY] -= 1.0;
            radians[(layor_n-1)*GRANURARITY + (peak-2)%GRANURARITY] -= 1.0;
        }
        if (layor_n<LAYERS-2) {
            radians[(layor_n+2)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.0;
            radians[(layor_n+2)*GRANURARITY + peak%GRANURARITY] -= 1.0;
            radians[(layor_n+2)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.0;
        }
        if (layor_n>1) {
            radians[(layor_n-2)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.0;
            radians[(layor_n-2)*GRANURARITY + peak%GRANURARITY] -= 1.0;
            radians[(layor_n-2)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.0;
        }
        
        for (int i=0; i<NUM_PARTICLES; i++)
        {
            if(radians[i]<0) radians[i] = 0.0;
        }
        
    }
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    // printf("mX: %d, mY: %d\n", ofGetMouseX(), ofGetMouseY());
    
    if(ofGetMouseY()>125 && ofGetMouseY()<475 && ofGetMouseX()>135 && ofGetMouseX()<185)
    {
        for (int k=0; k<999; k++) {
            myPoints[999-k] = myPoints[999-k-1];
        }
        
        
        layor_n = int(ofMap(ofGetMouseY(), 125.0, 475.0, LAYERS-1, 0.0));
        myPoints[0] = ofVec3f(peak, layor_n, 1.0);
        
        radians[layor_n*GRANURARITY + peak] -= 0.5;
        radians[layor_n*GRANURARITY + (peak+1)%GRANURARITY] -= 0.4;
        radians[layor_n*GRANURARITY + (peak-1)%GRANURARITY] -= 0.4;
        radians[layor_n*GRANURARITY + (peak-2)%GRANURARITY] -= 0.2;
        radians[layor_n*GRANURARITY + (peak+2)%GRANURARITY] -= 0.2;
        
        if(layor_n<LAYERS-1)
        {
            radians[(layor_n+1)*GRANURARITY + peak%GRANURARITY] -= 0.4;
            radians[(layor_n+1)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.3;
            radians[(layor_n+1)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.3;
            radians[(layor_n+1)*GRANURARITY + (peak+2)%GRANURARITY] -= 0.2;
            radians[(layor_n+1)*GRANURARITY + (peak-2)%GRANURARITY] -= 0.2;
        }
        if(layor_n>0)
        {
            radians[(layor_n-1)*GRANURARITY + peak%GRANURARITY] -= 0.4;
            radians[(layor_n-1)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.2;
            radians[(layor_n-1)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.2;
            radians[(layor_n-1)*GRANURARITY + (peak+2)%GRANURARITY] -= 0.2;
            radians[(layor_n-1)*GRANURARITY + (peak-2)%GRANURARITY] -= 0.2;
        }
        if (layor_n<LAYERS-2) {
            radians[(layor_n+2)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.2;
            radians[(layor_n+2)*GRANURARITY + peak%GRANURARITY] -= 0.2;
            radians[(layor_n+2)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.2;
        }
        if (layor_n>1) {
            radians[(layor_n-2)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.2;
            radians[(layor_n-2)*GRANURARITY + peak%GRANURARITY] -= 0.2;
            radians[(layor_n-2)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.2;
        }
        
    }
    
    for (int i=0; i<NUM_PARTICLES; i++)
    {
        if(radians[i]<0) radians[i] = 0.0;
    }
    
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
    
    
    if (myPoints[0].z == 0.0)
    {
        radians[y*GRANURARITY + x]                         += 2.0;
        radians[y*GRANURARITY + (x+1)%GRANURARITY]         += 1.8;
        radians[y*GRANURARITY + (x-1)%GRANURARITY]         += 1.8;
        radians[y*GRANURARITY + (x-2)%GRANURARITY]         += 1.0;
        radians[y*GRANURARITY + (x+2)%GRANURARITY]         += 1.0;
    
        if(y<LAYERS-1)
        {
            radians[(y+1)*GRANURARITY + x%GRANURARITY]     += 1.8;
            radians[(y+1)*GRANURARITY + (x+1)%GRANURARITY] += 1.5;
            radians[(y+1)*GRANURARITY + (x-1)%GRANURARITY] += 1.5;
            radians[(y+1)*GRANURARITY + (x+2)%GRANURARITY] += 1.0;
            radians[(y+1)*GRANURARITY + (x-2)%GRANURARITY] += 1.0;
        }
        if(y>0)
        {
            radians[(y-1)*GRANURARITY + x%GRANURARITY]     += 1.8;
            radians[(y-1)*GRANURARITY + (x+1)%GRANURARITY] += 1.5;
            radians[(y-1)*GRANURARITY + (x-1)%GRANURARITY] += 1.5;
            radians[(y-1)*GRANURARITY + (x+2)%GRANURARITY] += 1.0;
            radians[(y-1)*GRANURARITY + (x-2)%GRANURARITY] += 1.0;
        }
        if (y<LAYERS-2) {
            radians[(y+2)*GRANURARITY + (x-1)%GRANURARITY] += 1.0;
            radians[(y+2)*GRANURARITY + x%GRANURARITY]     += 1.0;
            radians[(y+2)*GRANURARITY + (x+1)%GRANURARITY] += 1.0;
        }
        if (y>1) {
            radians[(y-2)*GRANURARITY + (x-1)%GRANURARITY] += 1.0;
            radians[(y-2)*GRANURARITY + x%GRANURARITY]     += 1.0;
            radians[(y-2)*GRANURARITY + (x+1)%GRANURARITY] += 1.0;
        }
    }
    
    if (myPoints[0].z == 1.0)
    {
        radians[y*GRANURARITY + x]                         += 0.5;
        radians[y*GRANURARITY + (x+1)%GRANURARITY]         += 0.4;
        radians[y*GRANURARITY + (x-1)%GRANURARITY]         += 0.4;
        radians[y*GRANURARITY + (x-2)%GRANURARITY]         += 0.2;
        radians[y*GRANURARITY + (x+2)%GRANURARITY]         += 0.2;
        
        if(y<LAYERS-1)
        {
            radians[(y+1)*GRANURARITY + x%GRANURARITY]     += 0.4;
            radians[(y+1)*GRANURARITY + (x+1)%GRANURARITY] += 0.3;
            radians[(y+1)*GRANURARITY + (x-1)%GRANURARITY] += 0.3;
            radians[(y+1)*GRANURARITY + (x+2)%GRANURARITY] += 0.2;
            radians[(y+1)*GRANURARITY + (x-2)%GRANURARITY] += 0.2;
        }
        if(y>0)
        {
            radians[(y-1)*GRANURARITY + x%GRANURARITY]     += 0.4;
            radians[(y-1)*GRANURARITY + (x+1)%GRANURARITY] += 0.3;
            radians[(y-1)*GRANURARITY + (x-1)%GRANURARITY] += 0.3;
            radians[(y-1)*GRANURARITY + (x+2)%GRANURARITY] += 0.2;
            radians[(y-1)*GRANURARITY + (x-2)%GRANURARITY] += 0.2;
        }
        if (y<LAYERS-2) {
            radians[(y+2)*GRANURARITY + (x-1)%GRANURARITY] += 0.2;
            radians[(y+2)*GRANURARITY + x%GRANURARITY]     += 0.2;
            radians[(y+2)*GRANURARITY + (x+1)%GRANURARITY] += 0.2;
        }
        if (y>1) {
            radians[(y-2)*GRANURARITY + (x-1)%GRANURARITY] += 0.2;
            radians[(y-2)*GRANURARITY + x%GRANURARITY]     += 0.2;
            radians[(y-2)*GRANURARITY + (x+1)%GRANURARITY] += 0.2;
        }
    }
    
        
    for(int k=0; k<998; k++)
    {
        myPoints[k] = myPoints[k+1];
    }
    myPoints[999] = ofVec3f(0,0,0);
    
}



void ofApp::prnButtonPressed()
{
    
    for (int t=0; t<NUM_PARTICLES/20; t++)
    {
        while (ofGetFrameNum()%200==0);
        ofxOscMessage m;
        m.setAddress("/radians");
        m.addIntArg(t);
        for (int s=0; s<20; s++)
        {
            m.addFloatArg(radians[t*20+s]);
        }
        sender.sendMessage(m);
        printf("msg\n");
    }
    printf("msg done.\n");
}


 
 
void ofApp::touchDownEvent(int x, int y)
{
    if(y>125 && y<475 && x>135 && x<185)
    {
        for (int k=0; k<999; k++) {
            myPoints[999-k] = myPoints[999-k-1];
        }
        
        
        layor_n = int(ofMap(y, 125.0, 475.0, LAYERS-1, 0.0));
        myPoints[0] = ofVec3f(peak, layor_n, 0.0);
        
        radians[layor_n*GRANURARITY + peak] -= 2.0;
        radians[layor_n*GRANURARITY + (peak+1)%GRANURARITY] -= 1.8;
        radians[layor_n*GRANURARITY + (peak-1)%GRANURARITY] -= 1.8;
        radians[layor_n*GRANURARITY + (peak-2)%GRANURARITY] -= 1.0;
        radians[layor_n*GRANURARITY + (peak+2)%GRANURARITY] -= 1.0;
        
        if(layor_n<LAYERS-1)
        {
            radians[(layor_n+1)*GRANURARITY + peak%GRANURARITY] -= 1.8;
            radians[(layor_n+1)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.5;
            radians[(layor_n+1)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.5;
            radians[(layor_n+1)*GRANURARITY + (peak+2)%GRANURARITY] -= 1.0;
            radians[(layor_n+1)*GRANURARITY + (peak-2)%GRANURARITY] -= 1.0;
        }
        if(layor_n>0)
        {
            radians[(layor_n-1)*GRANURARITY + peak%GRANURARITY] -= 1.8;
            radians[(layor_n-1)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.0;
            radians[(layor_n-1)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.0;
            radians[(layor_n-1)*GRANURARITY + (peak+2)%GRANURARITY] -= 1.0;
            radians[(layor_n-1)*GRANURARITY + (peak-2)%GRANURARITY] -= 1.0;
        }
        if (layor_n<LAYERS-2) {
            radians[(layor_n+2)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.0;
            radians[(layor_n+2)*GRANURARITY + peak%GRANURARITY] -= 1.0;
            radians[(layor_n+2)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.0;
        }
        if (layor_n>1) {
            radians[(layor_n-2)*GRANURARITY + (peak-1)%GRANURARITY] -= 1.0;
            radians[(layor_n-2)*GRANURARITY + peak%GRANURARITY] -= 1.0;
            radians[(layor_n-2)*GRANURARITY + (peak+1)%GRANURARITY] -= 1.0;
        }
        
        for (int i=0; i<NUM_PARTICLES; i++)
        {
            if(radians[i]<0) radians[i] = 0.0;
        }
        
    }
}


void ofApp::touchMoveEvent(int x, int y)
{
    if(y>125 && y<475 && x>135 && x<185)
    {
        for (int k=0; k<999; k++) {
            myPoints[999-k] = myPoints[999-k-1];
        }
        
        
        layor_n = int(ofMap(y, 125.0, 475.0, LAYERS-1, 0.0));
        myPoints[0] = ofVec3f(peak, layor_n, 1.0);
        
        radians[layor_n*GRANURARITY + peak] -= 0.5;
        radians[layor_n*GRANURARITY + (peak+1)%GRANURARITY] -= 0.4;
        radians[layor_n*GRANURARITY + (peak-1)%GRANURARITY] -= 0.4;
        radians[layor_n*GRANURARITY + (peak-2)%GRANURARITY] -= 0.2;
        radians[layor_n*GRANURARITY + (peak+2)%GRANURARITY] -= 0.2;
        
        if(layor_n<LAYERS-1)
        {
            radians[(layor_n+1)*GRANURARITY + peak%GRANURARITY] -= 0.4;
            radians[(layor_n+1)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.3;
            radians[(layor_n+1)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.3;
            radians[(layor_n+1)*GRANURARITY + (peak+2)%GRANURARITY] -= 0.2;
            radians[(layor_n+1)*GRANURARITY + (peak-2)%GRANURARITY] -= 0.2;
        }
        if(layor_n>0)
        {
            radians[(layor_n-1)*GRANURARITY + peak%GRANURARITY] -= 0.4;
            radians[(layor_n-1)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.2;
            radians[(layor_n-1)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.2;
            radians[(layor_n-1)*GRANURARITY + (peak+2)%GRANURARITY] -= 0.2;
            radians[(layor_n-1)*GRANURARITY + (peak-2)%GRANURARITY] -= 0.2;
        }
        if (layor_n<LAYERS-2) {
            radians[(layor_n+2)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.2;
            radians[(layor_n+2)*GRANURARITY + peak%GRANURARITY] -= 0.2;
            radians[(layor_n+2)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.2;
        }
        if (layor_n>1) {
            radians[(layor_n-2)*GRANURARITY + (peak-1)%GRANURARITY] -= 0.2;
            radians[(layor_n-2)*GRANURARITY + peak%GRANURARITY] -= 0.2;
            radians[(layor_n-2)*GRANURARITY + (peak+1)%GRANURARITY] -= 0.2;
        }
        
    }
    
    for (int i=0; i<NUM_PARTICLES; i++)
    {
        if(radians[i]<0) radians[i] = 0.0;
    }
}
