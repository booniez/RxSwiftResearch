//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by 袁量 on 2024/8/10.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
//        share()
//        print("华丽的分割线-------------------")
//        BehaviorRelay()
//        print("华丽的分割线-------------------")
//        amb()
//        print("华丽的分割线-------------------")
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let logVc = LogViewController()
        navigationController?.pushViewController(logVc, animated: true)
    }

}

// MARK: 操作符
extension ViewController {
    
    /// share
    private func share() {
        let observable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in
                print("[share] Observable executed")
            })
//            .share()
            .share(replay: 1, scope: .forever)

        /**
         share 会让序列 observable 之执行一次，如果没有 share，那么两个订阅 observable 就需要执行两次
         .share(replay: 1, scope: .forever) 会让数据得到缓存，例如下面的例子，第三秒的时候如果有缓存，那么会立即得到2，如果没有则会等到第四秒才拿到3
         */
        
        observable
            .subscribe(onNext: { value in
                print("[share] Subscriber 1: \(value)")
            })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            observable
                .subscribe(onNext: { value in
                    print("[share] Subscriber 2: \(value)")
                })
        }
        
//        observable
//            .subscribe(onNext: { value in
//                print("Subscriber 2: \(value)")
//            })

        // 输出:
        // Observable executed
        // Subscriber 1: 0
        // Subscriber 2: 0
        // Observable executed
        // Subscriber 1: 1
        // Subscriber 2: 1
        // ...
    }
    
    /// amb
    func amb() {
        // 第一个序列将在 0.5 秒后发出事件
        let firstObservable = Observable<Int>.create { observer in
                print("[amb] First Observable subscribed")
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    observer.onNext(1)
                    observer.onCompleted()
                }
                return Disposables.create {
                    print("[amb] First Observable disposed")
                }
            }
            .do(onSubscribe: {
                print("[amb] First Observable onSubscribe")
            }, onDispose: {
                print("[amb] First Observable onDispose")
            })

        // 第二个序列将在 1 秒后发出事件
        let secondObservable = Observable<Int>.create { observer in
                print("[amb] Second Observable subscribed")
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    observer.onNext(2)
                    observer.onCompleted()
                }
                return Disposables.create {
                    print("[amb] Second Observable disposed")
                }
            }
            .do(onSubscribe: {
                print("[amb] Second Observable onSubscribe")
            }, onDispose: {
                print("[amb] Second Observable onDispose")
            })

        // 使用 `amb` 操作符选择第一个发出事件的序列
        Observable.amb([firstObservable, secondObservable])
            .subscribe(onNext: { value in
                print("[amb] Received value: \(value)")
            })
            .disposed(by: disposeBag)
    }
        
}

//MARK: 几种不同的 subject
extension ViewController {
    func BehaviorRelay() {
        let relay = RxRelay.BehaviorRelay(value: "Initial Value")

        relay.subscribe(onNext: { value in
            print("Received value: \(value)")
        }).disposed(by: disposeBag)
    }
}
