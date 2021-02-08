import UIKit
import RxSwift

example(of: "just, of, from") {
    let one = 1
    let two = 2
    let three = 3

    let justObservable: Observable<Int> = Observable.just(one)
    
    let ofObservable: Observable<Int> = Observable.of(one, two, three)
    let ofObservableIntArrays: Observable<[Int]> = Observable.of([one, two, three])
    
    let fromObservable: Observable<Int> = Observable.from([one, two, three])
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable: Observable<Int> = Observable.of(one, two, three)
    
    observable.subscribe(onNext: { element in
        print(element)
    },
    onCompleted: {
        print("Completed!")
    })
}

example(of: "never") {
    let _ = Observable<Void>.never()
        .subscribe(onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed!")
        })
}

example(of: "dispose") {
    let observable = Observable.of("A", "B", "C")
    observable.subscribe { (event) in
        print(event.element ?? event)
    }
    .dispose()
}

example(of: "deferred") {
    let disposeBag = DisposeBag()
    
    var flip = false
    
    let factory: Observable<Int> = Observable.deferred {
        flip.toggle()
        
        guard flip else {
            return Observable.of(4, 5, 6)
        }
        return Observable.of(1, 2, 3)
    }
    
    for _ in 0...3 {
        factory.subscribe(onNext: { element in
            print(element, terminator: "")
        })
        .disposed(by: disposeBag)
        
        print()
    }
}

example(of: "Single") {
    let disposeBag = DisposeBag()
    
    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }
    
    func loadText(from name: String) -> Single<String> {
        
        return Single.create { single in
            let disposable = Disposables.create()
            
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.error(FileReadError.unreadable))
                return disposable
            }
            
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.error(FileReadError.encodingFailed))
                return disposable
            }
            
            single(.success(contents))
            return disposable
        }
    }
    
    func loadTextUsingObservables(from name: String) -> Observable<String> {
        return Observable.create { observer in
            let disposable = Disposables.create()
            
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                observer.onError(FileReadError.fileNotFound)
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                observer.onError(FileReadError.unreadable)
                return disposable
            }
            
            guard let contents = String(data: data, encoding: .utf8) else {
                observer.onError(FileReadError.encodingFailed)
                return disposable
            }
            
            observer.onNext(contents)
            return disposable
        }

    }
    
    loadTextUsingObservables(from: "Copyright")
        .subscribe { event in
            switch event {
            case .next(let string):
                print(string)
            case .error(let error):
                print(error)
            default:
                break
            }
        }
        .disposed(by: disposeBag)
}

// MARK: - Challenges

example(of: "never with do operator") {
    let disposeBag = DisposeBag()
    
    let observable = Observable<Any>.never()
    
    observable.do(onSubscribe: {
        print("On Subscribe")
    })
    .subscribe { event in
        print(event.element ?? event)
    }
    .disposed(by: disposeBag)
}

example(of: "never with debug operator") {
    let disposeBag = DisposeBag()
    
    let observable = Observable<Any>.never()
    
    observable.debug("Never with debug operator - Example")
        .subscribe(onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
        },
        onDisposed: {
            print("Disposed")
        })
        .disposed(by: disposeBag)
}


