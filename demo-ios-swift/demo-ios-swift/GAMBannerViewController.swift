//
//  GAMBannerViewController.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import UIKit
import GoogleMobileAds

class GAMBannerViewController: UIViewController {

    var bannerView: DFPBannerView!

    //MARK: Properties
    @IBOutlet weak var loadBannerButton: UIButton!
    @IBOutlet weak var targetingOutput: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.rootViewController = self
    }

    //MARK: Actions

    @IBAction func loadBannerWithTargeting(_ sender: UIButton) {
        do {
            targetingOutput.text = "Calling /targeting API...\n\n"

            try OPTABLE!.targeting() { result in
                var tdata: NSDictionary = [:]

                switch result {
                case .success(let keyvalues):
                    print("[OptableSDK] Success on /targeting API call: \(keyvalues)")

                    tdata = keyvalues

                    DispatchQueue.main.async {
                        self.targetingOutput.text += "Data: \(keyvalues)\n"
                    }

                case .failure(let error):
                    print("[OptableSDK] Error on /targeting API call: \(error)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "Error: \(error)\n"
                    }
                }

                self.loadBanner(adUnitID: "/22081946781/ios-sdk-demo/mobile-leaderboard", keyvalues: tdata)
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
        }
    }

    private func loadBanner(adUnitID: String, keyvalues: NSDictionary) {
        bannerView.adUnitID = adUnitID

        let req = DFPRequest()
        req.customTargeting = keyvalues as! [String: Any]
        bannerView.load(req)

        do {
            try OPTABLE!.witness(event: "GAMBannerViewController.loadBannerClicked", properties: ["example": "value"]) { result in
                switch result {
                case .success(let response):
                    print("[OptableSDK] Success on /witness API call: response.statusCode = \(response.statusCode)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "\nSuccess calling witness API to log loadBannerClicked event.\n"
                    }

                case .failure(let error):
                    print("[OptableSDK] Error on /witness API call: \(error)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "\nError: \(error)"
                    }
                }
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
        }
    }

    private func addBannerViewToView(_ bannerView: DFPBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints([
            NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
             NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
     }

}
