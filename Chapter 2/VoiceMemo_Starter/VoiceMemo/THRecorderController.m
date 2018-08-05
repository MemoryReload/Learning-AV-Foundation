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
{
    THMeterTable* _meterTable;
}

- (NSString*)documentDirectory
{
    NSArray* docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return docs[0];
}

- (NSString*)cacheFilePath
{
    NSString *cachePath = NSTemporaryDirectory();
    NSString* filePath= [[cachePath stringByAppendingPathComponent:CACHE_FILE_NAME] stringByAppendingPathExtension:CACHE_FILE_EXTENSION];
    NSLog(@"Cache file path: %@",filePath);
    return filePath;
}

- (id)init {
    self = [super init];
    if (self) {
        NSError* error;
        _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:[self cacheFilePath]] settings:@{
                                                                                                  AVFormatIDKey:@(kAudioFormatAppleIMA4),
                                                                                                  AVSampleRateKey:@44100.0f,
                                                                                                  AVNumberOfChannelsKey:@1,
                                                                                                  AVEncoderBitDepthHintKey:@16,
                                                                                                  AVEncoderAudioQualityKey:@(AVAudioQualityMedium)
                                                                                                  
                                                                                                  } error:&error];
        if (_recorder) {
            _recorder.delegate = self;
            _recorder.meteringEnabled=YES;
            _meterTable = [[THMeterTable alloc]init];
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
    NSDateFormatter* fmt =[[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"YYYY-MM-HH:mm:ss"];
    NSString* fileName = [NSString stringWithFormat:@"%@_%@",name.length?name:CACHE_FILE_NAME,[fmt stringFromDate:[NSDate date]]];
    NSString* destFilePath = [[[self documentDirectory] stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:CACHE_FILE_EXTENSION];
    NSError* error;
    BOOL result;
    result = [[NSFileManager defaultManager] copyItemAtPath:[self cacheFilePath] toPath:destFilePath error:&error];
    if (result) {
        THMemo* memo = [THMemo memoWithTitle:name url:[NSURL URLWithString:destFilePath]];
        handler(YES,memo);
    }
    else{
        NSLog(@"Copy cache file failed : %@", error);
        handler(NO,error);
    }
}

- (THLevelPair *)levels {
    [self.recorder updateMeters];
    CGFloat averageDBPower = [self.recorder averagePowerForChannel:0];
    CGFloat peakDBPower    = [self.recorder peakPowerForChannel:0];
    CGFloat averageLinearPower = [_meterTable valueForPower:averageDBPower];
    CGFloat peakLinearPower = [_meterTable valueForPower:peakDBPower];
    NSLog(@"Linear average:%g peak:%g",averageLinearPower,peakLinearPower);
    return [[THLevelPair alloc]initWithLevel:averageLinearPower peakLevel:peakLinearPower];
}

- (NSString *)formattedCurrentTime {
    NSInteger time = floor(self.recorder.currentTime);
    NSInteger second = time%60;
    NSInteger minute = time/60%60;
    NSInteger hour = time/(60*60)%60;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
}

- (BOOL)playbackMemo:(THMemo *)memo {
    [self.player stop];
    NSError* error;
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:memo.url error:&error];
    if (self.player) {
        [self.player play];
        return YES;
    }
    else{
        NSLog(@"Setup play failed: %@",error);
    }
    return NO;
}

@end
