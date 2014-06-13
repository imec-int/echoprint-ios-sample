//
//  echoprintViewController.h
//  echoprint
//
//  Created by Brian Whitman on 6/13/11.
//  Copyright 2011 The Echo Nest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>  
#import "TSLibraryImport.h"
#import "MicrophoneInput.h"

#import "FPGenerator.h"


// change this to the server where you are running https://github.com/mixbe/node-echoprint-server:
#define API_HOST @"localhost:3000"

@interface echoprintViewController : UIViewController <MPMediaPickerControllerDelegate> {
	BOOL recording;
	IBOutlet UIButton* recordButton;
	IBOutlet UILabel* statusLine;
	MicrophoneInput* recorder;

}

- (IBAction)pickSong:(id)sender;
- (IBAction)startMicrophone:(id)sender;
- (void) getSong: (NSString*) fpCode;
@property (retain, nonatomic) IBOutlet UILabel *lblArtist;
@property (retain, nonatomic) IBOutlet UILabel *lblTrack;

@end

