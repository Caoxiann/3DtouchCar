//
//  ViewController.h
//  3DtouchCar
//
//  Created by 陈浩贤 on 2016/11/7.
//  Copyright © 2016年 陈浩贤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreBluetooth/CoreBluetooth.h>
#define kServiceUUID @"72A7518B-AA1C-4F1C-8409-0A67ADA1ED0C" //服务的UUID
#define writeCharacteristicUUID @"00001101-0000-1000-8000-00805F9B34FB" //特征的UUID

@interface ViewController : UIViewController
<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *rotationLabel;
@property CMMotionManager *manager;
@property NSOperationQueue *queue;
@property NSOperationQueue *acceQueue;
@property NSOperationQueue *mainQueue;
@property CBCharacteristic *writeCharacteristic;
@property NSTimer *timer;
@property float pressure;
@property int diretion;//0前进 1后退
@property float pitch;
@property (strong,nonatomic) CBCentralManager *centralManager;//中心设备管理器
@property (strong,nonatomic) NSMutableArray *peripherals;//连接的外围设备
@property (weak, nonatomic) IBOutlet UITextView *log;//日志记录

- (IBAction)startClick:(id)sender;
- (IBAction)switchDirection:(id)sender;

@end

