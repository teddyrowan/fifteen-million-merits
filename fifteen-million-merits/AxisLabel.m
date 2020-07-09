//
//  AxisLabel.m
//  fifteen-million-merits
//
//  Created by TR on 2020-07-07.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import "AxisLabel.h"

@implementation AxisLabel

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.numberOfLines      = 2;
        self.textAlignment      = NSTextAlignmentCenter;
        self.backgroundColor    = [UIColor colorWithWhite:1 alpha:0.15];
        self.font               = [UIFont systemFontOfSize:12];
    }

    return self;
}

@end
