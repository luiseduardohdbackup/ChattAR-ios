//
//  QBStorage.h
//  ChattAR
//
//  Created by Igor Alefirenko on 15/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBStorage : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSMutableArray *chatHistory;
@property (nonatomic, strong) NSMutableDictionary *allQuickBloxHistoryConversation;
@property (nonatomic, strong) QBChatRoom *currentChatRoom;
@property (nonatomic, strong) QBUUser *me;

+ (instancetype)shared;


#pragma mark -
#pragma mark Chache

- (void)saveHistory;
- (void)loadHistory;

@end
