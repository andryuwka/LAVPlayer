//
//  LAVAudioReqResult.h
//  LAVPlayer
//
//  Created by Andrew Lebedev on 20.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAVAudioReqResult : NSObject

@property (nonatomic, strong, readwrite) NSString *artist;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *url;
@property (nonatomic, strong, readwrite) NSNumber *audio_id;
@property (nonatomic, strong, readwrite) NSNumber *owner_id;
@property (nonatomic, strong, readwrite) NSNumber *lyrics_id;
@property (nonatomic, strong, readwrite) NSNumber *genre_id;
@property (nonatomic, strong, readwrite) NSNumber *duration;
@property (nonatomic, strong, readwrite) NSNumber *date;

- (id)initWithArtist:(NSString *)artist
                date:(NSNumber *)date
            duration:(NSNumber *)duration
            genre_id:(NSNumber *)genre_id
            audio_id:(NSNumber *)audio_id
           lyrics_id:(NSNumber *)lyrics_id
            owner_id:(NSNumber *)owner_id
               title:(NSString *)title
                 url:(NSString *)url;
- (NSString *) description;

- (BOOL)isEqual:(LAVAudioReqResult*)object;


@end
