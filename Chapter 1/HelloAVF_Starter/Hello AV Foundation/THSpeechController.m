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

#import "THSpeechController.h"
#import <AVFoundation/AVFoundation.h>

@interface THSpeechController ()

@end

@implementation THSpeechController
@synthesize synthesizer=_synthesizer;
@synthesize voices=_voices;
@synthesize speechStrings=_speechStrings;

+ (instancetype)speechController {
    return [[self alloc] init];
}

-(AVSpeechSynthesizer *)synthesizer
{
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc]init];
    }
    return _synthesizer;
}

-(NSArray *)voices
{
    if (!_voices) {
        _voices = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"],
                    [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"]];
    }
    return _voices;
}

-(NSArray *)speechStrings
{
    if (!_speechStrings) {
        _speechStrings = @[@"Hello AV Foundation. How are you?",
                           @"我很好谢谢关心！",
                           @"Are you excited about the book?",
                           @"非常兴奋！我总是感觉被人误解。",
                           @"What's your favorite feature?",
                           @"噢，他们都是我的宝贝，我很难抉择。",
                           @"It was great to speak with you!",
                           @"我也很高兴！玩的开心！"
                           ];
    }
    return _speechStrings;
}

- (void)beginConversation {    
    for (int i=0; i<self.speechStrings.count; i++) {
        AVSpeechUtterance* utterance = [[AVSpeechUtterance alloc]initWithString:self.speechStrings[i]];
        utterance.voice=[self.voices objectAtIndex:i%2];
        utterance.rate = 0.4;
        utterance.pitchMultiplier = 0.8;
        utterance.postUtteranceDelay = 0.1;
        [self.synthesizer speakUtterance:utterance];
    }
}

@end
