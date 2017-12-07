//
//  ViewController.swift
//  White on Black Datamatrix Radar Demo
//
//  Created by Michael Langford on 12/7/17.
//  Copyright © 2017 Michael Langford. All rights reserved.
//

import UIKit
import DYQRCodeDecoder
import AVFoundation

class ViewController: UIViewController {

  var qrViewController:DYQRCodeDecoderViewController?
  var qrNavViewController:UINavigationController?

  @IBOutlet weak var label:UILabel!


  /**
   This presents a view controller that scans items. Point the device at the provided datamatrix code labeled "Datamatrix, Black Dots on White Label from Inversion". You do not need to print out the image to work. The image on the screen of a Late 2016 15" Macbook Pro with Touchbar will trigger it. You will see this information show up in the label:

   0100358394024035216479456795871719073110S663527004973

   What is scanned also has some unprintable characters. These are expected and are GS1 codes.  You can see that printed out in the debug print in the console.
      \u{1D}010035839402403521647945679587\u{1D}1719073110S66352\u{1D}7004973

   That is great, and what we need from things printed this way.

   However, not all datamatrix codes are printed this way.

   When you point the device at the datamatrix code labeled "Datamatrix, White Dots on Black Label", you will see it *does not* trigger this handler. This is the problem.

   Our particular use-case is medication labels. (This is not secret)

   The inversion of this image was done via http://pinetools.com/invert-image-colors with the item saved as a JPG. It is the one that works.

   Proposed solution:

   When a user sets AVMetadataObjectTypeDataMatrixCode as a AVCaptureMetadataOutput should also be examining an invert of the video stream, or at least periodic image captures with an invert. Or, the recognizing algorithm should be trained/manually inverted to work with white on black codes.

   An acceptable compromise from the perspective of the user of the API (if needed for performance reasons) would be to have two different levels of datamatrix: AVMetadataObjectTypeDataMatrixCodeDarkDotsLightBackground and AVMetadataObjectTypeDataMatrixCodeLightDotsDarkBackground with the current behavior used for the AVMetadataObjectTypeDataMatrixCodeDarkDotsLightBackground case. This allows people to opt into the additional computation.

   There are economic and material science reasons why "light on dark" coloration will be used in industry.

    White on black labels are part of the DataMatrix standard, and are also an *important* use case in both the medical sector, as well as the machine-labeling uses of DataMatrix.

   Datamatrix is suitable for embossing in physical materials, such as metal, and "white on black" is essential for reading codes done that way (for some materials).


   Also see:
    https://www.gs1.org/docs/barcodes/GS1_DataMatrix_Guideline.pdf
    https://www.iso.org/obp/ui/#iso:std:iso-iec:16022:ed-2:v1:en
    https://www.iso.org/standard/44230.html
     https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=4&ved=0ahUKEwjjto3PtfjXAhXry4MKHY5TAl0QFghFMAM&url=https%3A%2F%2F2016archive.gs1us.org%2Fgs1-us-library%2Fcommand%2Fcore_download%2Fentryid%2F768%2Fmethod%2Fattachment&usg=AOvVaw3J7ePrlSqUdQIxPQ456gEN

   Others having this issue:
     https://forums.developer.apple.com/thread/5376
     https://stackoverflow.com/questions/27580953/unable-to-read-white-on-black-data-matrix-barcode
 */
  @IBAction func tappedScanDatamatrixCodeButton(_ sender: Any) {
    AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
      guard granted else {
        return
      }

      let codeFindingHandler:(Bool, String?)->() = { succeeded, result in

        self.qrNavViewController?.dismiss(animated: true, completion: {
          self.qrViewController = nil
          self.qrNavViewController = nil
        })

        guard let result = result else{
          self.label.text = "\(Date()): \nScanned <nil>"
          return
        }

        guard result != "" else{
          self.label.text = "\(Date()): \nScanned <\"\">"
          return
        }

        debugPrint("result: \(result)")
        self.label.text = "\(Date()): \n<\(result)>"
      }

      guard let qrController = DYQRCodeDecoderViewController(completion:codeFindingHandler) else{
        return
      }

      DispatchQueue.main.async {

        qrController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        let qrNavController = UINavigationController(rootViewController:qrController)
        self.qrNavViewController = qrNavController
        self.qrViewController = qrController //keep a strong ref to prevent dealloc
        self.present(qrNavController, animated:true)
      }
    }
  }



}

