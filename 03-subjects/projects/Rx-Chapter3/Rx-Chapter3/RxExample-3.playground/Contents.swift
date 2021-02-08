import UIKit
import RxSwift
import RxCocoa

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    
    subject.on(.next("Is anyone listening?"))
    
    let subscriptionOne = subject.subscribe(onNext: { element in
        print(element)
    })
    
    subject.on(.next("Is anyone listening now?"))
    
    subject.onNext("Anyone there?")
}

example(of: "Publish Subject in action") {
    let subject = PublishSubject<Int>()
    
    subject.on(.next(1)) // subject emits 1
    
    // creating first subscriber
    let subscriberOne = subject.subscribe(onNext: { element in
        print("This is sub1: \(element)")
    }, onCompleted: { print("Sub1: Subject emitted the completed event") })
    
    subject.onNext(2)
    
    // creating second subscriber
    let subscriberTwo = subject.subscribe(onNext: { element in
        print("This is sub2: \(element)")
    },
    onCompleted: { print("Sub2: Subject emitted the completed event") })
    
    subject.onNext(3)
    
    subscriberOne.dispose()
    
    subject.onNext(4)
    
    subject.onCompleted()
    
    subject.onNext(5)
    
    subscriberTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    subject.subscribe { event in
        print("This is sub3")
        print(event.element ?? event)
    }
    .disposed(by: disposeBag)
    
    subject.onNext(6)
}

enum MyError: Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

example(of: "Behavior Subject in action") {
    let behaviorSubject = BehaviorSubject<String>(value: "Initial Value")
    let disposeBag = DisposeBag()
    
    behaviorSubject
        .subscribe { event in
            print(label: "This is sub1:", event: event)
        }
        .disposed(by: disposeBag)
    
    behaviorSubject.on(.next("X"))
 
    behaviorSubject.on(.error(MyError.anError))
    
    behaviorSubject
        .subscribe { event in
            print(label: "This is sub2:", event: event)
        }
        .disposed(by: disposeBag)
    
    behaviorSubject.onNext("Y") // won't be printed out
}

example(of: "Replay subject in action") {
    let replaySubject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    replaySubject.on(.next("1"))
    replaySubject.on(.next("2"))
    replaySubject.on(.next("3"))
    
    replaySubject
        .subscribe { event in
            print("This is sub1:", event.element ?? event)
        }
        .disposed(by: disposeBag)
    
    replaySubject
        .subscribe { event in
            print("This is sub2:", event.element ?? event)
        }
        .disposed(by: disposeBag)
    
    replaySubject.on(.next("4"))
    
    replaySubject.on(.error(MyError.anError))
    replaySubject.dispose()
    
    replaySubject
        .subscribe { event in
            print("This is sub3:", event.element ?? event)
        }
        .disposed(by: disposeBag)
}

example(of: "Publish Relay in action") {
    // You can only use next events with relays.
    // No error or completed events.
    let publishRelay = PublishRelay<String>()
    let disposeBag = DisposeBag()
    
    publishRelay.accept("1")
    
    publishRelay
        .subscribe(onNext: { element in
            print("This is sub1:", element)
        })
        .disposed(by: disposeBag)
    
    publishRelay.accept("2")
    publishRelay.accept("3")
    
    publishRelay
        .subscribe(onNext: { element in
            print("This is sub2:", element)
        })
        .disposed(by: disposeBag)
    
    publishRelay.accept("4")
}

example(of: "Behavior Relay in action") {
    let behaviorRelay = BehaviorRelay<String>(value: "Initial Value")
    let disposeBag = DisposeBag()
    
    behaviorRelay
        .subscribe(onNext: { element in
            print("This is sub1:", element)
        })
        .disposed(by: disposeBag)
    
    behaviorRelay.accept("1")
    
    behaviorRelay
        .subscribe(onNext: { element in
            print("This is sub2:", element)
        })
        .disposed(by: disposeBag)
    
    behaviorRelay.accept("2")
    
    print("current value: \(behaviorRelay.value)")
}

// MARK: - Challenge 1

example(of: "PublishSubject") {
  
  let disposeBag = DisposeBag()
  
  let dealtHand = PublishSubject<[(String, Int)]>()
  
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining = deck.count
        var hand = [(String, Int)]()
        
        for _ in 0..<cardCount {
            let randomIndex = Int.random(in: 0..<cardsRemaining)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }
        
        // Add code to update dealtHand here
        let pointsCalculated = points(for: hand)
        
        guard pointsCalculated > 21 else {
            dealtHand.on(.error(HandError.busted(points: pointsCalculated)))
            return
        }
        
        dealtHand.on(.next(hand))
    }
    
    // Add subscription to dealtHand here
    dealtHand
        .subscribe(onNext: { element in
            print(element)
        },
        onError: { error in
            print(error)
        })
        .disposed(by: disposeBag)
    
    deal(3)
}

// MARK: - Challenge 2

example(of: "BehaviorRelay") {
  enum UserSession {
    case loggedIn, loggedOut
  }
  
  enum LoginError: Error {
    case invalidCredentials
  }
  
  let disposeBag = DisposeBag()
  
  // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
    let behaviorRelay = BehaviorRelay<UserSession>(value: .loggedOut)

  // Subscribe to receive next events from userSession
    behaviorRelay
        .subscribe (onNext: { element in
            print(element)
        })
        .disposed(by: disposeBag)
  
  func logInWith(username: String, password: String, completion: (Error?) -> Void) {
    guard username == "johnny@appleseed.com",
          password == "appleseed" else {
      completion(LoginError.invalidCredentials)
      return
    }
    
    // Update userSession
    behaviorRelay.accept(.loggedIn)
  }
  
  func logOut() {
    // Update userSession
    behaviorRelay.accept(.loggedOut)
  }
  
  func performActionRequiringLoggedInUser(_ action: () -> Void) {
    // Ensure that userSession is loggedIn and then execute action()
    guard behaviorRelay.value == .loggedIn else { return }
    action()
  }
  
  for i in 1...2 {
    let password = i % 2 == 0 ? "appleseed" : "password"
    
    logInWith(username: "johnny@appleseed.com", password: password) { error in
      guard error == nil else {
        print(error!)
        return
      }
      
      print("User logged in.")
    }
    
    performActionRequiringLoggedInUser {
      print("Successfully did something only a logged in user can do.")
    }
  }
}

