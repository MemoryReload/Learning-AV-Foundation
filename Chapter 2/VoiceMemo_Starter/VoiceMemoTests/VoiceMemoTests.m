//
//  VoiceMemoTests.m
//  VoiceMemoTests
//
//  Created by HePing on 2018/8/5.
//  Copyright © 2018年 Bob McCune. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>
#import "THRecorderController.h"
#import "THMemo.h"

@interface VoiceMemoTests : XCTestCase
@property (nonatomic, strong) THRecorderController* controller;
@end

@implementation VoiceMemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPlayFailed{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    THMemo* memo = mock([THMemo class]);
    [given([memo url]) willReturn:nil];
    BOOL result = [self.controller playbackMemo:memo];
    assertThat(@(result), isFalse());
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
