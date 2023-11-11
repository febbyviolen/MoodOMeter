//
//  SubscriptionViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/07/23.
//

import UIKit
import Combine
import StoreKit
import NVActivityIndicatorView

class SubscriptionVC: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    @IBOutlet weak var thirdBenefitSubSubLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var fourthView: UIView!
    @IBOutlet weak var secondVIew: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var fourthBenefitSubLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    @IBOutlet weak var thirdBenefitLabel: UILabel!
    @IBOutlet weak var sceondBenefitLabel: UILabel!
    @IBOutlet weak var firstBenefitLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var retrieveButton: UIButton!
    
    
    private var model : SKProduct!
    private let userDefault = UserDefaults.standard
    private var activityIndicatorView: NVActivityIndicatorView! = IndicatorViewFactory.build()
    private let VM = SubscriptionVM()
    private var cancellable = Set<AnyCancellable>()
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
//        fetchProducts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //transaction observer
        setupUI()
        
        SKPaymentQueue.default().add(self)
        activityIndicatorView.startAnimating()
        fetchProducts()
        bind()
    }
    
    private func bind() {
        VM.$purchased
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] purchased in
                if purchased == "true" {
                    buyButton.isHidden = true
                    retrieveButton.isHidden = true
                    VM.setPremiumPass(to: "true")
                } else {
                    buyButton.isHidden = false
                    retrieveButton.isHidden = false
                    VM.setPremiumPass(to: "false")
                }
            }
            .store(in: &cancellable)
    }
    
    //MARK: BUTTON
    @IBAction func retrieveButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @IBAction func buyButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        if model != nil {
            let payment = SKPayment(product: model!)
            SKPaymentQueue.default().add(payment)
        } else {
            activityIndicatorView.stopAnimating()
            let alert = UIAlertController(title: String(format: NSLocalizedString("실패했습니다", comment: "")), message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: String(format: NSLocalizedString("네", comment: "")), style: .default, handler: nil)
            self.present(alert, animated: true)
        }
    }
    
    // === product request delegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            guard let product = response.products.first else {
                // Handle the case when no products are available
                print("NO PRODUCT")
                return
            }
            // Rest of the implementation...
            self.model = product
            self.setupPriceInfo()
        }
    }
    
    private func fetchProducts(){
        let request = SKProductsRequest(productIdentifiers: Set(Subscription.allCases.compactMap({$0.rawValue})))
        print(Subscription.allCases.compactMap({$0.rawValue}))
        //product request delegate
        request.delegate = self
        request.start()
    }
    
    // === transaction observer
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        activityIndicatorView.stopAnimating()
            transactions.forEach ({
                switch $0.transactionState {
                case.purchased:
                    print("purchased")
                    self.VM.purchased = "true"
                    self.VM.preventInterupttedReceipt()
                    
                    queue.finishTransaction($0)
                    break
                case .failed:
                    print("failed")
                    self.VM.purchased = "false"
                    
                    let alert = UIAlertFactory.buildOneAlert(
                        title: "실패했습니다".localised, 
                        message: "",
                        okAction: UIAlertAction(title: "네".localised,
                                                style: .default,
                                                handler: nil))
                  
                    present(alert, animated: true)
                    
                    queue.finishTransaction($0)
                case .restored:
                    print("restored")
                    self.VM.purchased = "true"
                    self.VM.preventInterupttedReceipt()
                    
                    queue.finishTransaction($0)
                default:
                    print("on purchase..")
                    activityIndicatorView.startAnimating()
                }
            })
        }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        print("paymentQueue shouldAddStorePayment ")
        return true
    }
    
}

extension SubscriptionVC {
    private func setupPriceInfo() {
        priceLabel.text = "\(model.priceLocale.currencySymbol ?? "₩")\(model.price)"
        activityIndicatorView.stopAnimating()
    }
    
    private func setupUI() {
        [firstView, secondVIew, thirdView, fourthView, buyButton].forEach {
            $0?.addCornerRadius(radius: 16)
        }
        self.view.addSubview(activityIndicatorView)
        
        let str = NSAttributedString(string: "retrieve.premium".localised, attributes: [
            .font: UIFont.systemFont(ofSize: 12)
        ])
        
        retrieveButton.setAttributedTitle(str, for: .normal)
    }
    
}
