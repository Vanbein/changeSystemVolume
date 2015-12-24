//
//  ViewController.m
//  change(SystemVolume
//
//  Created by 王斌 on 15/12/23.
//  Copyright © 2015年 Changhong electric Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController (){
    UISlider *volumeViewSlider;
    UISlider *VolSlider;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //不显示“铃声”，显示“音量”
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    
    //1. 获得 MPVolumeView 实例，
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, -100, 100, 100)];
    //volumeView.hidden = NO;
    //[self.view addSubview:volumeView]; //添加后不显示“音量”
    volumeViewSlider = nil;
    //2. 遍历MPVolumeView的subViews得到MPVolumeSlider
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    //3.获取系统音量
    float systemVolume = volumeViewSlider.value;
    //4.添加一个全局的 slider，滑动时同步改变系统音量
    VolSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 200, 300, 20)];
    VolSlider.value = systemVolume;  //初始值
    [VolSlider setMinimumValue:0.0]; //最小值
    [VolSlider setMaximumValue:1.0]; //最大值
    [VolSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged]; //添加事件
    [self.view addSubview:VolSlider];
    
    //注册监听实体键按下事件
    [self registeNotification];
}

- (void)dealloc{
    [self removeNotification];
}

//得到音量大小
//- (float)volume
//{
//    return [[MPMusicPlayerController applicationMusicPlayer] volume];
//}

- (void)registeNotification{
    //注册监听系统音量变化，记得在适当的地方移除监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void) removeNotification{
    //移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)volumeChanged:(NSNotification *)notification{
    
    //获取到当前音量
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    //同步改变VolSlider的值
    [VolSlider setValue:volume animated:YES];

}

- (void)sliderValueChange:(UISlider *)slider{
    
    //得到当前用户设置的value
    float value = slider.value;
    
    //改变系统音量大小，音量大小从 0.0 - 1.0
    [volumeViewSlider setValue:value animated:NO];
    //使UI事件立即发生，
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
