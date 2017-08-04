//
//  SeafBackgroundTaskManager.h
//  Pods
//
//  Created by Wei W on 4/9/17.
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "SeafPreView.h"
#import "SeafConnection.h"
#import "SeafUploadFile.h"

typedef void(^SyncBlock)();
// Manager for background download/upload tasks, retry if failed.
@interface SeafDataTaskManager : NSObject

@property (readonly) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *uploadingList;
@property (nonatomic, strong) NSMutableArray *downloadingList;

@property (nonatomic, copy) SyncBlock trySyncBlock;

+ (SeafDataTaskManager *)sharedObject;

- (void)startTimer;

- (unsigned long)backgroundUploadingNum;
- (unsigned long)backgroundDownloadingNum;

- (NSInteger)uploadingNum;
- (NSInteger)downloadingNum;

- (void)finishDownload:(id<SeafDownloadDelegate>)task result:(BOOL)result;
- (void)finishUpload:(SeafUploadFile *)file result:(BOOL)result;

- (void)addBackgroundUploadTask:(SeafUploadFile *)file;
- (void)addBackgroundDownloadTask:(id<SeafDownloadDelegate>)file;
- (void)removeBackgroundUploadTask:(SeafUploadFile *)file;
- (void)removeBackgroundDownloadTask:(id<SeafDownloadDelegate>)task;
- (void)cancelAutoSyncTasks:(SeafConnection *)conn;
- (void)cancelAutoSyncVideoTasks:(SeafConnection *)conn;

- (void)assetForURL:(NSURL *)assetURL resultBlock:(ALAssetsLibraryAssetForURLResultBlock)resultBlock failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;
@end
