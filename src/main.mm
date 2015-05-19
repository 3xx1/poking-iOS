#include "ofMain.h"
#include "ofApp.h"

int main(){
    ofSetupOpenGL(320,568,OF_FULLSCREEN);			// <-------- setup the GL context
    
    ofRunApp(new ofApp());
}
