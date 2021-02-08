/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RxSwift
import RxRelay

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!
  
  private let images = BehaviorRelay<[UIImage]>(value: [])
  private let disposeBag = DisposeBag()
  
  private struct Constants {
    static let maxPhotosAllowed: Int = 6
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // subscription to show images in the preview rectangle
    images
      .subscribe(onNext: { [weak imagePreview] photos in
        guard let preview = imagePreview else { return }
        preview.image = photos.collage(size: preview.frame.size)
      })
      .disposed(by: disposeBag)
    
    // subscription to update the UI
    images
      .subscribe(onNext: { [weak self] images in
        self?.updateUI()
      })
      .disposed(by: disposeBag)
  }
  
  private var enableClearButton: Bool {
    images.value.count > 0
  }
  
  private var enableSaveButton: Bool {
    guard images.value.count > 0 else {
      return false
    }
    
    guard images.value.count != 1 else {
      return true
    }
    
    guard images.value.count % 2 == 0 else {
      return false
    }
    return true
  }
  
  private var enableAddButton: Bool {
    images.value.count < 6
  }
  
  private func updateUI() {
    buttonClear.isEnabled = enableClearButton
    buttonSave.isEnabled = enableSaveButton
    itemAdd.isEnabled = enableAddButton
    title = images.value.count > 0 ? "\(images.value.count) Photos selected" : "Collage"
  }
  
  @IBAction func actionClear() {
    // clear the current selection
    images.accept([])
  }

  @IBAction func actionSave() {

  }

  @IBAction func actionAdd() {
    let newImage = UIImage(named: "IMG_1907")!
    let newImages = images.value + [newImage]
    images.accept(newImages)
  }

  func showMessage(_ title: String, description: String? = nil) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
    present(alert, animated: true, completion: nil)
  }
}
