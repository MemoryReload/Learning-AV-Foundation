//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THRecorderController.h"
#import <AVFoundation/AVFoundation.h>
#import "THMemo.h"
#import "THLevelPair.h"
#import "THMeterTable.h"

#define CACHE_FILE_NAME              @"voice"
#define CACHE_FILE_EXTENSION         @"caf"

@interface THRecorderController () <AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) THRecordingStopCompletionHandler completionHandler;

@end

@implementation THRecorderController

- (NSString*)documentDirectory
{
    NSArray* docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return docs[0];
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *cachePath = NSTemporaryDirectory();
        NSString* filePath= [[cachePath stringByAppendingPathComponent:CACHE_FILE_NAME] stringByAppendingPathExtension:CACHE_FILE_EXTENSION];
        NSLog(@"Cache file path: %@",filePath);
        NSError* error;
        _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:filePath] settings:@{
                                                                                                  AVFormatIDKey:@(kAudioFormatAppleIMA4),
                                                                                                  AVSampleRateKey:@44100.0f,
                                                                                                  AVNumberOfChannelsKey:@1,
                                                                                                  AVEncoderBitDepthHintKey:@16,
                                                                                                  AVEncoderAudioQualityKey:@(AVAudioQualityMedium)
                                                                                                  
                                                                                                  } error:&error];
        if (_recorder) {
            _recorder.delegate = self;
            [_recorder prepareToRecord];
        }
        else{
            NSLog(@"Init AVAudioRecoder fail: %@", error.localizedDescription);
        }
    }
    return self;
}

- (BOOL)record {
    return [self.recorder record];
}

- (void)pause {
    [self.recorder pause];
}

- (void)stopWithCompletionHandler:(THRecordingStopCompletionHandler)handler {
    self.completionHandler = handler;
    [self.recorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)success {
    if (self.completionHandler) {
        self.completionHandler(success);
    }
}

- (void)saveRecordingWithName:(NSString *)name completionHandler:(THRecordingSaveCompletionHandler)handler {

}

- (THLevelPair *)levels {
    return nil;
}

- (NSString *)formattedCurrentTime {
    return @"00:00:00";
}

- (BOOL)playbackMemo:(THMemo *)memo {
    return NO;
}

@end
