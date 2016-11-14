//
//  Bluetooth.h
//  3DtouchCar
//
//  Created by 陈浩贤 on 2016/11/8.
//  Copyright © 2016年 陈浩贤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface Bluetooth : NSObject

@property (strong,nonatomic) CBPeripheralManager *peripheralManager;//外围设备管理器

@property (strong,nonatomic) NSMutableArray *centralM;//订阅此外围设备特征的中心设备

@property (strong,nonatomic) CBMutableCharacteristic *characteristicM;//特征



@end
