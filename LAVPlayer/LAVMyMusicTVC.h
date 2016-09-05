//
//  LAVMyMusicTVC.h
//  LAVPlayer
//
//  Created by Andrew Lebedev on 19.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAVMyMusicTVC : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong, readwrite) NSArray *trackList;
@property (nonatomic, weak, readwrite) IBOutlet UITableView *tableView;

- (void)setTrackList:(NSArray *)trackList;

@end

