//
//  KitTableViewCell.h
//  KitDemo
//
//  Created by libo on 16/3/30.
//  Copyright © 2016年 Timlee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KitTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *secTitle;
@property (weak, nonatomic) IBOutlet UILabel *details;
@property (weak, nonatomic) IBOutlet UILabel *subDetails;

@end
