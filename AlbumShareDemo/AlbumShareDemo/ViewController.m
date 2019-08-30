//
//  ViewController.m
//  AlbumShareDemo
//
//  Created by Zzzz on 2019/8/29.
//  Copyright © 2019 Zzzz. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
//#import "SDAVAssetExportSession.h"

#define APP_FOLDER_NAME     @"DachengShareFile"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *imageDataArray;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSString *storagePath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSFileManager *manager = [NSFileManager defaultManager];
//    NSError *error;
//    BOOL success = [manager removeItemAtPath:fileUrl error:&error];
//    if (success) {
//        DCLog(@"删除共享文件");
//    }
    
    
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        
        
        NSLog(@"album title %@", collection.localizedTitle);
        
        
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
                        //                                            NSLog(@"videoPath = %@",videoPath);
                        
                        if ([videoPath hasSuffix:@"IMG_7361.MOV"]) {//IMG_7362.mp4    IMG_7361.MOV
                            
                            self.asset = asset;
                            
                            
                            //Caches文件夹
                            NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

                            NSString *outPath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d12345.mp4",arc4random()%100]];
                            NSLog(@"videoPath:%@",outPath);

//                            AVURLAsset *anAsset = [[AVURLAsset alloc]initWithURL:[NSURL URLWithString:videoPath] options:nil];
//                            SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:anAsset];
//                            encoder.outputFileType = @"com.apple.quicktime-movie";
//                            encoder.outputURL = [NSURL URLWithString:outPath];
//                            encoder.videoSettings = @{
//                                                      AVVideoCodecKey: AVVideoCodecH264,
//                                                      AVVideoWidthKey: @160,
//                                                      AVVideoHeightKey: @284,
//                                                      AVVideoCompressionPropertiesKey: @
//                                                      {
//                                                      AVVideoAverageBitRateKey: @130000,
//                                                      AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel,
//                                                      },
//                                                      };
//
//
//                            [encoder exportAsynchronouslyWithCompletionHandler:^
//                             {
//                                 NSLog(@"2============%f",    encoder.progress);
//                                 if (encoder.status == AVAssetExportSessionStatusCompleted)
//                                 {
//
//                                     NSLog(@"Video export succeeded");
//                                 }
//                                 else if (encoder.status == AVAssetExportSessionStatusCancelled)
//                                 {
//                                     NSLog(@"Video export cancelled");
//                                 }
//                                 else
//                                 {
//                                     NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);
//                                 }
//                             }];
                            
                            
                            
                            
                            // Option
//                            PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
//                            option.version = PHVideoRequestOptionsVersionCurrent; // default
//                            option.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic; // default
//
//                            // Manager
//                            PHImageManager *manager = [PHImageManager defaultManager];
//                            [manager requestExportSessionForVideo:self.asset options:option exportPreset:AVAssetExportPresetMediumQuality  resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
//
//                                // Export
//                                exportSession.outputURL = [NSURL URLWithString:outPath];
//                                exportSession.shouldOptimizeForNetworkUse = YES;
//                                exportSession.outputFileType = AVFileTypeMPEG4; // mp4
//                                [exportSession exportAsynchronouslyWithCompletionHandler:^{
//                                    switch ([exportSession status]) {
//                                        case AVAssetExportSessionStatusFailed:{
//                                            NSLog(@"failed");
//                                        }break;
//                                        case AVAssetExportSessionStatusCompleted:{
//                                            NSLog(@"completed!");
//                                        }break;
//                                        default:
//                                            break;
//                                    }
//                                }];
//                            }];
                            
                            
                            
                            
                            
                            
                            // Option
                            PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
                            option.version = PHVideoRequestOptionsVersionCurrent; // default
                            option.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic; // default
                            
                            // Manager
                            PHImageManager *manager = [PHImageManager defaultManager];
                            [manager requestExportSessionForVideo:self.asset options:option exportPreset:AVAssetExportPresetMediumQuality  resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                                
                                NSURL *outputURL = [NSURL fileURLWithPath:outPath];
                                
                                AVURLAsset *urlAsset = (AVURLAsset *)exportSession.asset;
                                
                                AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset: urlAsset presetName:AVAssetExportPresetMediumQuality];
                                
                                session.outputURL = outputURL;
                                
                                session.outputFileType = AVFileTypeMPEG4;
                                
                                [session exportAsynchronouslyWithCompletionHandler:^(void){
                                    
                                    NSLog(@"2============%f====%@",    session.progress,outputURL);
                                    if (session.status == AVAssetExportSessionStatusCompleted)
                                    {
                                        
                                        NSLog(@"Video export succeeded");
                                    }
                                    else if (session.status == AVAssetExportSessionStatusCancelled)
                                    {
                                        NSLog(@"Video export cancelled");
                                    }
                                    else
                                    {
                                        NSLog(@"Video export failed with error: %@ (%ld)", session.error.localizedDescription, (long)session.error.code);
                                    }
                                    
                                }];
                                
                                
                                
//                                AVURLAsset *anAsset = (AVURLAsset *)exportSession.asset;
//                                SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:anAsset];
//                                encoder.outputFileType = @"com.apple.quicktime-movie";
//                                encoder.outputURL = outputURL;
//                                encoder.videoSettings = @{
//                                                          AVVideoCodecKey: AVVideoCodecTypeH264,
//                                                          AVVideoWidthKey: @160,
//                                                          AVVideoHeightKey: @284,
//                                                          AVVideoCompressionPropertiesKey: @
//                                                          {
//                                                          AVVideoAverageBitRateKey: @130000,
//                                                          AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel,
//                                                          },
//                                                          };
//
//
//                                [encoder exportAsynchronouslyWithCompletionHandler:^
//                                 {
//                                     NSLog(@"2============%f",    encoder.progress);
//                                     if (encoder.status == AVAssetExportSessionStatusCompleted)
//                                     {
//
//                                         NSLog(@"Video export succeeded");
//                                     }
//                                     else if (encoder.status == AVAssetExportSessionStatusCancelled)
//                                     {
//                                         NSLog(@"Video export cancelled");
//                                     }
//                                     else
//                                     {
//                                         NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);
//                                     }
//                                 }];
                                
                                
                                
                                
                            }];
                            
                            
                            
                            
                            
                        }
                    }
                }
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
    self.storagePath = [groupPath stringByAppendingPathComponent:APP_FOLDER_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_storagePath]) {
        [fileManager createDirectoryAtPath:_storagePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return _storagePath;
}


@end
