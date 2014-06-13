//
//  echoprintViewController.m
//  echoprint
//
//  Created by Brian Whitman on 6/13/11.
//  Copyright 2011 The Echo Nest. All rights reserved.
//

#import "echoprintViewController.h"
#import "ASIHTTPRequest.h"

@implementation echoprintViewController

- (IBAction)pickSong:(id)sender {
	NSLog(@"Pick song");
	MPMediaPickerController* mediaPicker = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic] autorelease];
	mediaPicker.delegate = self;
	[self presentViewController:mediaPicker animated:YES completion:nil];
	
}
- (IBAction) startMicrophone:(id)sender {
	if(recording) {
		recording = NO;
		[recorder stopRecording];
		[recordButton setTitle:@"Listen" forState:UIControlStateNormal];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = paths[0];
		NSString *filePath =[documentsDirectory stringByAppendingPathComponent:@"output.caf"];
		[statusLine setText:@"analysing..."];
		[statusLine setNeedsDisplay];
		[self.view setNeedsDisplay];
        NSString* fpCode = [FPGenerator generateFingerprintForFile:filePath];
        [self getSong:fpCode];
	} else {
		[statusLine setText:@"listening..."];
        self.lblArtist.text = @"";
        self.lblTrack.text = @"";
		recording = YES;
		[recordButton setTitle:@"Stop en analyze" forState:UIControlStateNormal];
		[recorder startRecording];
		[statusLine setNeedsDisplay];
		[self.view setNeedsDisplay];
	}
	NSLog(@"what");

}


- (void)mediaPicker:(MPMediaPickerController *)mediaPicker 
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	[self dismissViewControllerAnimated:YES completion:nil];
	for (MPMediaItem* item in mediaItemCollection.items) {
		NSString* title = [item valueForProperty:MPMediaItemPropertyTitle];
		NSURL* assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
		NSLog(@"title: %@, url: %@", title, assetURL);
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = paths[0];

		NSURL* destinationURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"temp_data"]];
		[[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
		TSLibraryImport* import = [[TSLibraryImport alloc] init];
		[import importAsset:assetURL toURL:destinationURL completionBlock:^(TSLibraryImport* import) {
			//check the status and error properties of
			//TSLibraryImport
			NSString *outPath = [documentsDirectory stringByAppendingPathComponent:@"temp_data"];
			NSLog(@"done now. %@", outPath);
			[statusLine setText:@"analysing..."];
			
            NSString* fpCode = [FPGenerator generateFingerprintForFile:outPath];
            
			[statusLine setNeedsDisplay];
			[self.view setNeedsDisplay];
			[self getSong:fpCode];
		}];
		
	}
}


- (void) getSong: (NSString*) fpCode {
	NSLog(@"Done %@", fpCode);

    NSString *apiString = [NSString stringWithFormat:@"http://%@/query?version=4.12&code=%@", API_HOST, fpCode];
    
    NSURL *url = [NSURL URLWithString:apiString];
	
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
	[request setAllowCompressedResponse:NO];
	[request startSynchronous];
	NSError *error = [request error];
	if (!error) {
		NSString *response = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
		NSLog(@"%@", dictionary);
		if([[dictionary objectForKey:@"success"] boolValue] == true) {
			NSString * song_title = dictionary[@"match"][@"track"];
			NSString * artist_name = dictionary[@"match"][@"artist"];
            self.lblArtist.text = artist_name;
            self.lblTrack.text = song_title;
			[statusLine setText:[NSString stringWithFormat:@"%@ - %@", artist_name, song_title]];
		} else {
			[statusLine setText:@"No match, try a longer sample"];
		}
	} else {
		[statusLine setText:@"some error"];
		NSLog(@"error: %@", error);
	}
	[statusLine setNeedsDisplay];
	[self.view setNeedsDisplay];
}



- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissViewControllerAnimated:YES completion:nil];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	recorder = [[MicrophoneInput alloc] init];
	recording = NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [_lblArtist release];
    [_lblTrack release];
    [super dealloc];
}

@end
