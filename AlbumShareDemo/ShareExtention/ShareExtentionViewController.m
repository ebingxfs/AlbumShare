//
//  ShareExtentionViewController.m
//  Share
//
//  Created by Zzzz on 2019/7/30.
//  Copyright © 2019 Zzzz. All rights reserved.
//

#import "ShareExtentionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "SDAVAssetExportSession.h"

#define APP_FOLDER_NAME     @"DachengShareFile"

@interface ShareExtentionViewController ()

@property (nonatomic, strong) NSMutableArray *imageDataArray;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSString *storagePath;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ShareExtentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载动画初始化
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.frame = CGRectMake((self.view.frame.size.width - activityIndicatorView.frame.size.width) / 2,
                                             (self.view.frame.size.height - activityIndicatorView.frame.size.height) / 2,
                                             activityIndicatorView.frame.size.width,
                                             activityIndicatorView.frame.size.height);
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

    [self.view addSubview:activityIndicatorView];
    
    self.activityIndicatorView = activityIndicatorView;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    //激活加载动画
    [activityIndicatorView startAnimating];
    
    self.imageDataArray = [NSMutableArray array];
    
    
    //扩展中的处理不能太长时间阻塞主线程,放入线程中处处理，否则可能导致苹果拒绝你的应用
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        //extensionContext表示一个扩展到host app的连接，通过extionContext,你可以访问一个NSExtensionItem的数组，每一个NSExtensionItem项表示从host app传回的一个逻辑单元。
        for (NSExtensionItem *item in self.extensionContext.inputItems) {
            
            
            NSInteger count = item.attachments.count;
            
            //可以从NSExtensionItem项中的attachments属性中获得附件数据，如音频、视频、图片等，NSItemProvide就是实例的表示
            for (NSItemProvider *itemProvider in item.attachments) {
                
                //NSLog(@"%@-----%@",itemProvider,item);
                
                if ([itemProvider hasItemConformingToTypeIdentifier:@"public.image"]) {
                
                    
                    //item Url类型：file:///var/mobile/Media/PhotoData/OutgoingTemp/0F2F2637-0DBF-44F2-8F89-EFD9579BB76E/RenderedPhoto/IMG_0185.JPG
                    
                    [itemProvider loadItemForTypeIdentifier:[itemProvider.registeredTypeIdentifiers firstObject] options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                        
                        // 对itemProvider夹带着的图片进行解析
                        NSURL *imageUrl = (NSURL *)item;
                        
                        if (imageUrl) {
                            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
                            [dataDic setObject:[NSString stringWithFormat:@"%@",imageUrl] forKey:@"imageUrl"];
                            NSData *data = [NSData dataWithContentsOfURL:imageUrl];
                            [dataDic setObject:data forKey:@"data"];
                            [self.imageDataArray addObject:dataDic];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (self.imageDataArray.count == count) {
                                
                                //NSLog(@"%@", [NSString stringWithFormat:@"获取全部%ld张照片",(long)count]);
                                //name同App groups匹配
                                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:[NSString stringWithFormat:@"group.%@",bundleIdentifier]];
                                
                                //存图片数组
                                [userDefaults setObject:self.imageDataArray forKey:@"shareImageDataArray"];
                                //用于标记是新的分享
                                [userDefaults setBool:YES forKey:@"newShare"];
                                
                                [activityIndicatorView stopAnimating];
                                //获取全部再销毁
                                [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                                
                                NSURL *destinationURL = [NSURL URLWithString:[NSString stringWithFormat:@"dachenmedicalcircle://%@",@"saveFilePath"]];
                                NSString *className = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x55, 0x49, 0x41, 0x70, 0x70, 0x6C, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E} length:13] encoding:NSASCIIStringEncoding];
                                if (NSClassFromString(className)) {
                                    id object = [NSClassFromString(className) performSelector:@selector(sharedApplication)];
                                    [object performSelector:@selector(openURL:) withObject:destinationURL];
                                }
                            } else {
                                [activityIndicatorView stopAnimating];
                            }
                        });
                        
                    }];
                }else {
                    
                    [self videoHandle:itemProvider];
                }
            }
        }
    });
}

-(void)videoHandle:(NSItemProvider *)itemProvider
{
    //public.mpeg-4           com.apple.quicktime-movie
    [itemProvider loadItemForTypeIdentifier:@"public.movie" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
        
        // 对itemProvider夹带着的图片进行解析
        NSURL *videoUrl = (NSURL *)item;
        
        NSString *videoName = [videoUrl lastPathComponent];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:[NSString stringWithFormat:@"group.%@",bundleIdentifier]];
        
        NSURL *uotPutPath;
        NSString *outputStr = [NSString stringWithFormat:@"%@/%.0f%d.mp4",self.storagePath,[[NSDate date] timeIntervalSince1970],arc4random()%100];
        if ([outputStr hasPrefix:@"file://"]) {
            uotPutPath = [NSURL URLWithString:outputStr];
        } else {
            uotPutPath = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",outputStr]];
        }
        
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        
        [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
            
            PHFetchOptions *options = [PHFetchOptions new];
            
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeVideo];
            
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                PHAsset *asset = (PHAsset*)obj;
                
                [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                    NSString *filePath = [info valueForKey:@"PHImageFileSandboxExtensionTokenKey"];
                    if (filePath && filePath.length > 0) {
                        NSArray *lyricArr = [filePath componentsSeparatedByString:@";"];
                        NSString *privatePath = [lyricArr lastObject];
                        if (privatePath.length > 8) {
                            NSString *videoPath = [privatePath substringFromIndex:8];
                            if ([videoPath hasSuffix:videoName]) {
                                
                                self.asset = asset;
                                
                                // Option
                                PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
                                option.version = PHVideoRequestOptionsVersionCurrent; // default
                                option.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic; // default
                                
                                // Manager
                                PHImageManager *manager = [PHImageManager defaultManager];
                                [manager requestExportSessionForVideo:self.asset options:option exportPreset:AVAssetExportPresetMediumQuality  resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                                    
                                    AVURLAsset *anAsset = (AVURLAsset *)exportSession.asset;
                                    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:anAsset];
                                    encoder.outputFileType = @"com.apple.quicktime-movie";
                                    encoder.outputURL = uotPutPath;
                                    encoder.videoSettings = @{
                                                              AVVideoCodecKey: AVVideoCodecH264,
                                                              AVVideoWidthKey: @(self.view.frame.size.width),
                                                              AVVideoHeightKey: @(self.view.frame.size.height),
                                                              AVVideoCompressionPropertiesKey: @
                                                              {
                                                              AVVideoAverageBitRateKey: @(2*self.view.frame.size.width*self.view.frame.size.height),
                                                              AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel,
                                                              },
                                                              };
                                    
                                    
                                    [encoder exportAsynchronouslyWithCompletionHandler:^
                                     {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             
                                             [self.activityIndicatorView stopAnimating];
                                             NSLog(@"00============%f",    encoder.progress);
                                             if (encoder.status == AVAssetExportSessionStatusCompleted)
                                             {
                                                 NSLog(@"Video export succeeded");
                                                 NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
                                                 [dataDic setObject:[NSString stringWithFormat:@"%@",uotPutPath] forKey:@"imageUrl"];
                                                 [dataDic setObject:uotPutPath.absoluteString forKey:@"videoURL"];
                                                 
                                                 [self.imageDataArray addObject:dataDic];
                                                 
                                                 //存图片数组
                                                 [userDefaults setObject:self.imageDataArray forKey:@"shareImageDataArray"];
                                                 //用于标记是新的分享
                                                 [userDefaults setBool:YES forKey:@"newShare"];
                                                 
                                                 
                                                 //获取全部再销毁
                                                 [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                                                 
                                                 NSURL *destinationURL = [NSURL URLWithString:[NSString stringWithFormat:@"AlbumShareDemo://%@",@"saveFilePath"]];
                                                 NSString *className = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x55, 0x49, 0x41, 0x70, 0x70, 0x6C, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E} length:13] encoding:NSASCIIStringEncoding];
                                                 if (NSClassFromString(className)) {
                                                     id object = [NSClassFromString(className) performSelector:@selector(sharedApplication)];
                                                     [object performSelector:@selector(openURL:) withObject:destinationURL];
                                                 }
                                                 
                                             }
                                             else if (encoder.status == AVAssetExportSessionStatusCancelled)
                                             {
                                                 NSLog(@"Video export cancelled");
                                             }
                                             else
                                             {
                                                 NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);
                                             }
                                         });
                                     }];
                                }];
                            }
                        }
                    }
                }];
            }];
        }];
    }];
}


- (NSString *)storagePath
{
    if (_storagePath) {
        return _storagePath;
    }
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[NSString stringWithFormat:@"group.%@",bundleIdentifier]];
    NSString *groupPath = [groupURL path];
    _storagePath = [groupPath stringByAppendingPathComponent:APP_FOLDER_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:_storagePath error:&error];
    if (success) {
        NSLog(@"删除共享文件夹");
    }
    
    if (![fileManager fileExistsAtPath:_storagePath]) {
        [fileManager createDirectoryAtPath:_storagePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return _storagePath;
}

@end
