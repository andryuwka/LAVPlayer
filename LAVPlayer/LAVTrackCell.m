//
//  LAVTrackCell.m
//  LAVPlayer
//
//  Created by Andrew Lebedev on 04.01.16.
//  Copyright © 2016 Andrew Lebedev. All rights reserved.
//

#import "LAVTrackCell.h"

@interface LAVTrackCell ()

@property (nonatomic, weak, readwrite) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *labelArtist;
@property (nonatomic, strong, readwrite) NSString *url;

@end

@implementation LAVTrackCell



- (void)awakeFromNib {
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setArtist:(NSString *)artist title:(NSString *)title andUrl:(NSString *)url {
    self.labelTitle.text = title;
    self.labelArtist.text = artist;
    self.url = url;
}


@end
