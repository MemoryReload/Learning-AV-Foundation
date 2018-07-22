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

#import "THPlayerController.h"
#import <AVFoundation/AVFoundation.h>

@implementation THPlayerController
{
    NSArray* _players;
}

-(void)dealloc
{
    [self removeNotifications];
}

#pragma mark - initilization methods
-(instancetype)init
{
    self = [super init];
    if (self) {
        _playing=NO;
        [self initializePlayers];
        [self registerNotifications];
    }
    return self;
}

-(void)initializePlayers
{
    _players =@[[self playerForFile:@"guitar"],
                [self playerForFile:@"bass"],
                [self playerForFile:@"drums"]];
}

-(AVAudioPlayer*)playerForFile:(NSString*)name
{
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"caf"];
    NSError* error;
    AVAudioPlayer* player = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
    if (player) {
        player.numberOfLoops = -1; //indefinitely loop
        player.enableRate = YES;
        [player prepareToPlay];
    }
    else{
        NSLog(@"Create player failed: %@", [error localizedDescription]);
    }
    return player;
}

#pragma mark - notification manage methods
-(void)registerNotifications
{
    //注册音频打断通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
}

-(void)removeNotifications
{
    //注销音频打断通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

#pragma mark - playback methods
- (void)play {
    if (!_playing) {
        NSTimeInterval delayTime = [(AVAudioPlayer*)_players[0] deviceCurrentTime]+0.01;
        [_players enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [(AVAudioPlayer*)obj playAtTime:delayTime];
        }];
        self.playing=YES;
    }
}

- (void)stop {
    if (_playing) {
        [_players enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AVAudioPlayer* player = obj;
            [player stop];
            player.currentTime=0;
        }];
        self.playing=NO;
    }
}

- (void)adjustRate:(float)rate {
    [_players enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AVAudioPlayer* player = obj;
        player.rate = rate;
    }];
}

- (void)adjustPan:(float)pan forPlayerAtIndex:(NSUInteger)index {
    AVAudioPlayer* player = [_players objectAtIndex:index];
    player.pan=pan;
}

- (void)adjustVolume:(float)volume forPlayerAtIndex:(NSUInteger)index {
    AVAudioPlayer* player = [_players objectAtIndex:index];
    player.volume = volume;
}

#pragma mark - AudioSessionInterruptionNotification handling
-(void)handleAudioSessionInterruptionNotification:(NSNotification*)noti
{
    AVAudioSessionInterruptionType type = [[[noti userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        //stop the players
        [self stop];

        BOOL isSuspended = [[[noti userInfo] objectForKey:AVAudioSessionInterruptionWasSuspendedKey] boolValue];
        if (isSuspended) {
            //the app is suspended,and now starts running again, do some thing if necessary.
            [self play];
        }
    }
    else if (type == AVAudioSessionInterruptionTypeEnded){
        //If audio session should be resume, resume the play.
        AVAudioSessionInterruptionOptions option = [[[noti userInfo] objectForKey:AVAudioSessionInterruptionOptionKey] integerValue];
        if (option == AVAudioSessionInterruptionOptionShouldResume) {
            [self play];
        }
    }
}
@end
