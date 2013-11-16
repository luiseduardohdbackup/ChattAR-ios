//
//  QBStorage.m
//  ChattAR
//
//  Created by Igor Alefirenko on 15/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.

#import "QBStorage.h"
#import "Utilites.h"

@implementation QBStorage

+ (instancetype)shared {
    static QBStorage *defaultQBStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultQBStorage = [[self alloc] init];
    });
    return defaultQBStorage;
}

- (id)init {
    if (self = [super init]) {
        self.chatHistory = [[NSMutableArray alloc] init];
        self.allQuickBloxHistoryConversation = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark -
#pragma mark Chache

- (void)saveHistory {
    NSMutableDictionary *historyToCache = [self archiveData];
    // archiving:
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:historyToCache forKey:@"certificate"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadHistory {
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self dataFilePath]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableDictionary *cache = [unarchiver decodeObjectForKey:@"certificate"];
    [unarchiver finishDecoding];
}

- (NSMutableDictionary *)archiveData {
    NSMutableDictionary *data = self.allQuickBloxHistoryConversation;
    NSArray *keys = [data allKeys];
    NSMutableDictionary *cachedHistory = [[NSMutableDictionary alloc] init];
    for (NSString *key in keys) {
        // unpack messages:
        NSMutableDictionary *messageDictionary = [data objectForKey:key];
        NSMutableArray *arrayOfMessages = [messageDictionary objectForKey:kMessage];
        // adding new array for saving converted messages:
        NSMutableArray *convertedMessages = [[NSMutableArray alloc] init];
        for (QBChatMessage *message in arrayOfMessages) {
            NSMutableDictionary *msg = [self convertMessageToDictionary:message];
            [convertedMessages addObject:msg];
        }
        NSMutableDictionary *newData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:convertedMessages,kMessage, nil];
        [cachedHistory setObject:newData forKey:key];
    }
    return cachedHistory;
}

- (void)unarchiveData {
    
}

// convertors:
- (NSMutableDictionary *)convertMessageToDictionary:(QBChatMessage *)message {
    NSMutableDictionary *newMessage = [[NSMutableDictionary alloc] init];
    NSString *dateTime = [[Utilites shared].dateFormatter stringFromDate:message.datetime];
    [newMessage setObject:dateTime forKey:kDateTime];
    [newMessage setObject:message.text forKey:kMessage];
    [newMessage setObject:[NSString stringWithFormat:@"%i", message.recipientID] forKey:kRecepientID];
    [newMessage setObject:[NSString stringWithFormat:@"%i", message.senderID] forKey:kSenderID];
    [newMessage setObject: message.ID forKey:kId];
    return newMessage;
}

- (QBChatMessage *)convertDictionaryToMessage:(NSMutableDictionary *)dictionary {
    QBChatMessage *newMessage = [[QBChatMessage alloc]init];
    newMessage.ID = [dictionary objectForKey:kId];
    newMessage.recipientID = [[dictionary objectForKey:kRecepientID] intValue];
    newMessage.senderID = [[dictionary objectForKey:kSenderID] intValue];
    NSString *dateString = [dictionary objectForKey:kDateTime];
    newMessage.datetime = [[Utilites shared].dateFormatter dateFromString:dateString];
    newMessage.text = [dictionary objectForKey:kMessage];
    return newMessage;
}


#pragma mark -
#pragma mark NSSearchDirectory

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *fullPath = [documentsDirectory stringByAppendingString:kFilename];
    return fullPath;
}

@end
