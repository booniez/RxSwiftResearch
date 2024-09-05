//
//  LogService.swift
//  RxSwiftTest
//
//  Created by yuanl on 2024/9/4.
//

import Foundation
import RxSwift

class LogService {
    static func sendLog() -> Observable<String> {
        // 模拟一个日志发送请求，返回一个 Observable
        return Observable<String>.create { observer in
            // 假设这是一个耗时操作，Observable 本身处理异步
            print("[BackgroundTask]日志发送中...")
            observer.onNext("[BackgroundTask]日志发送中...")
            observer.onCompleted()
            return Disposables.create()
        }
//        .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .flatMap { _ -> Observable<String> in
            return Observable.create { observer in
                // 在这里执行异步任务
                sleep(5) // 模拟一个耗时操作
                print("[BackgroundTask]日志发送成功")
                observer.onNext("[BackgroundTask]日志发送成功")
                observer.onCompleted()
                return Disposables.create()
            }
        }
    }
}
