//
//  LAVAudioReqResult.m
//  LAVPlayer
//
//  Created by Andrew Lebedev on 20.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "LAVAudioReqResult.h"

@implementation LAVAudioReqResult

- (id)initWithArtist:(NSString *)artist
                date:(NSNumber *)date
            duration:(NSNumber *)duration
            genre_id:(NSNumber *)genre_id
            audio_id:(NSNumber *)audio_id
           lyrics_id:(NSNumber *)lyrics_id
            owner_id:(NSNumber *)owner_id
               title:(NSString *)title
                 url:(NSString *)url {

  self = [super init];

  self.artist = artist;
  self.date = date;
  self.duration = duration;
  self.genre_id = genre_id;
  self.audio_id = audio_id;
  self.lyrics_id = lyrics_id;
  self.owner_id = owner_id;
  self.title = title;
  self.url = url;

  return self;
}

- (NSString *)description {
  NSString *d = [NSString
      stringWithFormat:@"\nartist = %@\ndate = %@\nduration = %@\n"
                       @"genre_id = %@\naudio_id = %@\nlyrics_id = %@\n"
                       @"owner_id = %@\ntitle = %@\nurl = %@", self.artist, self.date, self.duration,
                       self.genre_id, self.audio_id, self.lyrics_id,
                       self.owner_id, self.title, self.url];
  return d;
}

- (BOOL)isEqual:(LAVAudioReqResult *)object {
    return ([object.title isEqualToString:self.title]);
}

@end
