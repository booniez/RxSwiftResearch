//
//  LogViewController.swift
//  RxSwiftTest
//
//  Created by yuanl on 2024/9/4.
//

import UIKit
import RxSwift

class LogViewController: UIViewController {

       let disposeBag = DisposeBag()

       override func viewDidLoad() {
           super.viewDidLoad()
           view.backgroundColor = .white
           testObservableDisposal()
       }
    
    func testObservableDisposal() {
        let disposeBag2 = DisposeBag()
        
        // Create an outer observable
        let outerObservable = Single<Void>.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(NSError(domain: "SuuntoDeviceService", code: -1, userInfo: [NSLocalizedDescriptionKey: "SuuntoDeviceService deallocated"])))
                return Disposables.create()
            }
            
            print("Outer Observable Created")
            
            // Create an inner observable
            let innerObservable = Observable<Int>.create { observer in
                print("Inner Observable Created")
                observer.onNext(1)
                observer.onCompleted()
                return Disposables.create {
                    print("Inner Observable Disposed")
                }
            }
            
            // Subscribe to the inner observable
            innerObservable
                .subscribe(onNext: { value in
                    print("Inner Observable Emitted Value: \(value)")
                    observer(.success(()))
                })
                .disposed(by: self.disposeBag)
            
            // Clean up the outer observable
            return Disposables.create {
                print("Outer Observable Disposed")
            }
        }
        
        // Subscribe to the outer observable
        outerObservable
            .subscribe(onSuccess: { _ in
                print("subscribe Outer Observable onSuccess")
            }, onFailure: { _ in
                print("subscribe Outer Observable onFailure")
            })
            .disposed(by: disposeBag)
        
        // Trigger disposal by disposing the disposeBag
        // The disposables should be triggered here
    }

       func sendLog() {
           // 创建一个发送日志的 Observable
           LogService.sendLog()
               .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
               .observe(on: MainScheduler.instance) // 确保在主线程中处理 UI 相关的操作
//               .takeUntil(self.rx.deallocated) // 当页面被释放(deinit)时停止接收消息
               .subscribe(onNext: { result in
                   // 当页面还在时处理日志发送结果
                   print("[BackgroundTask]日志发送结果: \(result)")
               }, onError: { error in
                   // 处理错误
                   print("[BackgroundTask]日志发送错误: \(error)")
               })
               .disposed(by: disposeBag)
       }
}
