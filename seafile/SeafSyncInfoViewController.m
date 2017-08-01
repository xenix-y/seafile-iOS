//
//  SeafUpDownloadViewController.m
//  seafilePro
//
//  Created by three on 2017/7/29.
//  Copyright © 2017年 Seafile. All rights reserved.
//

#import "SeafSyncInfoViewController.h"
#import "SeafSyncInfoCell.h"
#import "Debug.h"
#import "SeafDataTaskManager.h"
#import "SeafFile.h"
#import "SeafPhoto.h"

static NSString *cellIdentifier = @"SeafSyncInfoCell";

@interface SeafSyncInfoViewController ()<SeafDentryDelegate>

@property (nonatomic, strong) NSArray *syncArray;

@end

@implementation SeafSyncInfoViewController

-(instancetype)initWithType:(DETAILTYPE)type
{
    self = [super init];
    if (self) {
        self.detailType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"SeafSyncInfoCell" bundle:nil]
         forCellReuseIdentifier:cellIdentifier];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeAll;

    if (self.detailType == DOWNLOAD_DETAIL) {
        self.navigationItem.title = @"正在下载";
    } else {
        self.navigationItem.title = @"正在上传";
    }
    
    if (self.detailType == DOWNLOAD_DETAIL) {
        self.syncArray = [NSArray arrayWithArray:SeafDataTaskManager.sharedObject.downloadingList];
    } else {
        self.syncArray = [NSArray arrayWithArray:SeafDataTaskManager.sharedObject.uploadingList];
    }
    [self.tableView reloadData];
    
    WS(weakSelf);
    SeafDataTaskManager.sharedObject.trySyncBlock = ^{
        @autoreleasepool {
            if (weakSelf.detailType == DOWNLOAD_DETAIL) {
                weakSelf.syncArray = [NSArray arrayWithArray:SeafDataTaskManager.sharedObject.downloadingList];
            } else {
                weakSelf.syncArray = [NSArray arrayWithArray:SeafDataTaskManager.sharedObject.downloadingList];
            }
        }
        [weakSelf.tableView reloadData];
    };

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.syncArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SeafSyncInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.progressView setProgress:0];
    SeafFile *sfile = self.syncArray[indexPath.row];
    sfile.delegate = self;

    cell.nameLabel.text = sfile.name;
    cell.pathLabel.text = sfile.path;
    cell.iconView.image = sfile.icon;
    
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.iconView.image drawInRect:imageRect];
    cell.iconView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.sizeLabel.text = sfile.detailText;
    
    if (sfile.state == SEAF_DENTRY_INIT) {
        cell.progressView.hidden = YES;
    } else {
        cell.progressView.hidden = NO;
    }
    
    return cell;
}

#pragma mark - SeafDentryDelegate
- (void)download:(SeafBase *)entry progress:(float)progress
{
    Debug(@"%f", progress);
    if (entry.state == SEAF_DENTRY_LOADING) {
        SeafSyncInfoCell *cell = [self getEntryCell:entry];
        if (cell) {
            if (progress) {
                cell.progressView.hidden = NO;
                [cell.progressView setProgress:progress];
            }
        }
    }
}

- (void)download:(SeafBase *)entry complete:(BOOL)updated
{
    
}

- (void)download:(SeafBase *)entry failed:(NSError *)error
{
    
}

- (SeafSyncInfoCell *)getEntryCell:(id)entry
{
    NSUInteger index = [self.syncArray indexOfObject:entry];
    if (index == NSNotFound)
        return nil;
    @try {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        return (SeafSyncInfoCell *)[self.tableView cellForRowAtIndexPath:path];
    } @catch(NSException *exception) {
        Warning("Something wrong %@", exception);
        return nil;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
