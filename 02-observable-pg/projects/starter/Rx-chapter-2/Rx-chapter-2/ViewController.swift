//
//  ViewController.swift
//  Rx-chapter-2
//
//  Created by ayush mahajan on 04/02/21.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Observable.of("RxSwift")
    }
}

