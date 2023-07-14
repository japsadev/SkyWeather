//
//  FourthViewController.swift
//  iWeather
//
//  Created by Salih Yusuf Göktaş on 5.07.2023.
//

import UIKit

class FourthViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let qrGif = UIImage.gifImageWithName("fromKamiAnimation")
		imageView.image = qrGif
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
