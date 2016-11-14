//
//  ViewController.m
//  3DtouchCar
//
//  Created by 陈浩贤 on 2016/11/7.
//  Copyright © 2016年 陈浩贤. All rights reserved.
//

#import "ViewController.h"
CMAttitude *initialAttitude;
int count=0;
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (self.manager==nil) {
        self.manager=[[CMMotionManager alloc]init];
    }
    self.queue=[[NSOperationQueue alloc]init];
    self.acceQueue=[[NSOperationQueue alloc]init];
    self.mainQueue=[[NSOperationQueue alloc]init];
    
    self.peripherals=[[NSMutableArray alloc]init];
    self.manager.gyroUpdateInterval=0.1;
    self.manager.accelerometerUpdateInterval=0.1;
    if (!self.manager.isGyroAvailable) {
        return;
    }
    self.log.layoutManager.allowsNonContiguousLayout=false;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.15 repeats:YES block:^(NSTimer *timer) {
        if (self.pressure>=0.8&&[self.peripherals lastObject]) {
            [self writePressure:self.pressure];
        }
    }];
    self.diretion=0;
    [self getAttitude];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSArray *touchArray=[touches allObjects];
    UITouch *touch=[touchArray lastObject];
    self.pressure=touch.force;
    self.rotationLabel.text=[NSString stringWithFormat:@"pitch:%f",self.pitch];
    _pressureLabel.text=[NSString stringWithFormat:@"pressure:%f",touch.force];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.pressure=0;
}

-(void)pushGyro{
    [self.manager startGyroUpdatesToQueue:self.queue withHandler:^(CMGyroData *gyroData,NSError *error){
        if (error) {
            return;
        }
        CMRotationRate rotationRate=gyroData.rotationRate;
        NSLog(@"x:%f y:%f z:%f", rotationRate.x, rotationRate.y, rotationRate.z);
        self.rotationLabel.text=[NSString stringWithFormat:@"x:%f y:%f z:%f", rotationRate.x, rotationRate.y, rotationRate.z];
    }];
}

-(void)pushAccelerometer{
    [self.manager startAccelerometerUpdatesToQueue:self.acceQueue withHandler:^(CMAccelerometerData *acceData,NSError *error){
        NSLog(@"x:%f y:%f z:%f",acceData.acceleration.x,acceData.acceleration.y,acceData.acceleration.z);
        self.rotationLabel.text=[NSString stringWithFormat:@"x:%f y:%f z:%f",acceData.acceleration.x,acceData.acceleration.y,acceData.acceleration.z];
        
    }];
}

-(void)getAttitude{
    if (self.manager.deviceMotionAvailable) {
        [self.manager startDeviceMotionUpdatesToQueue:self.mainQueue withHandler:^(CMDeviceMotion *data,NSError *error){
            if (error) {
                return;
            }
            CMAttitude *attitute=data.attitude;
            self.pitch=attitute.pitch;
        }];
    }else{
        NSLog(@"no ok");
    }
    
}

-(void)writeToLog:(NSString *)info{
    self.log.text=[NSString stringWithFormat:@"%@\r\n%@",self.log.text,info];
    NSInteger strLength=[self.log.text length];
    [self.log scrollRangeToVisible:NSMakeRange(0, strLength)];
    
}


- (IBAction)startClick:(id)sender {
    if (self.centralManager==nil) {
        self.centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }else{
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    
}

- (IBAction)switchDirection:(id)sender {
    if (self.diretion==0) {
        self.diretion=1;
    }else{
        self.diretion=0;
    }
}


//中心服务器状态更新后
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"BLE已打开.");
            [self writeToLog:@"BLE已打开."];
            //扫描外围设备
            //            [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
            
        default:
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.");
            [self writeToLog:@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备."];
            break;
    }
}
/**
 *  发现外围设备
 *
 *  @param central           中心设备
 *  @param peripheral        外围设备
 *  @param advertisementData 特征数据
 *  @param RSSI              信号质量（信号强度）
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"发现外围设备...");
    [self writeToLog:@"发现外围设备..."];
    //停止扫描
    [self.centralManager stopScan];
    //连接外围设备
    if (peripheral) {
        //添加保存外围设备，注意如果这里不保存外围设备（或者说peripheral没有一个强引用，无法到达连接成功（或失败）的代理方法，因为在此方法调用完就会被销毁
        if(![self.peripherals containsObject:peripheral]){
            [self.peripherals addObject:peripheral];
        }
        NSLog(@"开始连接外围设备...");
        [self writeToLog:@"开始连接外围设备..."];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    
}
//连接到外围设备
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接外围设备成功!");
    [self writeToLog:@"连接外围设备成功!"];
    //添加到数组中
    [self.peripherals addObject:peripheral];
    //设置外围设备的代理为当前视图控制器
    peripheral.delegate=self;
    //外围设备开始寻找服务
    [peripheral discoverServices:nil];
    
    
}


//连接外围设备失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外围设备失败!");
    [self writeToLog:@"连接外围设备失败!"];
}

//外围设备寻找到服务后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"已发现可用服务...");
    [self writeToLog:@"已发现可用服务..."];
    if(error){
        NSLog(@"外围设备寻找服务过程中发生错误，错误信息：%@",error.localizedDescription);
        [self writeToLog:[NSString stringWithFormat:@"外围设备寻找服务过程中发生错误，错误信息：%@",error.localizedDescription]];
    }
    //遍历查找到的服务
    NSLog(@"services:%@",peripheral.services);
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//外围设备寻找到特征后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"已发现可用特征...");
    [self writeToLog:@"已发现可用特征..."];
    if (error) {
        NSLog(@"外围设备寻找特征过程中发生错误，错误信息：%@",error.localizedDescription);
        [self writeToLog:[NSString stringWithFormat:@"外围设备寻找特征过程中发生错误，错误信息：%@",error.localizedDescription]];
    }
    //遍历服务中的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        //情景一：通知
        /*找到特征后设置外围设备为已通知状态（订阅特征）：
         *1.调用此方法会触发代理方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
         *2.调用此方法会触发外围设备的订阅代理方法
         */
        
//        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        //情景二：读取
//        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFF0"]]) {
//            [peripheral readValueForCharacteristic:characteristic];
//            if(characteristic.value){
//                NSString *value=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//                NSLog(@"读取到特征值：%@",value);
//            }
//        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]) {
            self.writeCharacteristic=characteristic;
            NSLog(@"service:%@ charateristic:%@",service,characteristic);
        }
        
        
    }

}
//特征值被更新后
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"收到特征更新通知...");
    [self writeToLog:@"收到特征更新通知..."];
    if (error) {
        NSLog(@"更新通知状态时发生错误，错误信息：%@",error.localizedDescription);
    }
    //给特征值设置新的值
    if (characteristic.isNotifying) {
        if (characteristic.properties==CBCharacteristicPropertyNotify) {
            NSLog(@"已订阅特征通知.");
            [self writeToLog:@"已订阅特征通知."];
            return;
        }else if (characteristic.properties ==CBCharacteristicPropertyRead) {
            //从外围设备读取新值,调用此方法会触发代理方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
            [peripheral readValueForCharacteristic:characteristic];
        }
        
    }else{
        NSLog(@"停止已停止.");
        [self writeToLog:@"停止已停止."];
        //取消连接
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}
//更新特征值后（调用readValueForCharacteristic:方法或者外围设备在订阅后更新特征值都会调用此代理方法）
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"更新特征值时发生错误，错误信息：%@",error.localizedDescription);
        [self writeToLog:[NSString stringWithFormat:@"更新特征值时发生错误，错误信息：%@",error.localizedDescription]];
        return;
    }
    if (characteristic.value) {
        NSString *value=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"读取到特征值：%@",value);
        [self writeToLog:[NSString stringWithFormat:@"读取到特征值：%@",value]];
    }else{
        NSLog(@"未发现特征值.");
        [self writeToLog:@"未发现特征值."];
    }
}

-(void)writePressure:(float)pressure{
    NSData *data=[[NSString stringWithFormat:@"%6.3fa%6.3fb%dc",pressure,self.pitch,self.diretion]dataUsingEncoding:NSUTF8StringEncoding];
    for (CBPeripheral *peripheral in self.peripherals) {
        if (self.writeCharacteristic) {
            [peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
            NSLog(@"%d",self.diretion);
        }
    }
          
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"%@",error);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    if (error) {
        NSLog(@"%@",error);
    }
}

@end
