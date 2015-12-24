
import UIKit

protocol HolderViewDelegate:class {
    func loadScreenFinished()
}

class HolderView: UIView {

  let redRectangleLayer = RectangleLayer()
  let blueRectangleLayer = RectangleLayer()
  let arcLayer = ArcLayer()
    var box:UIView!
  //var parentFrame :CGRect = CGRectZero
  weak var delegate:HolderViewDelegate?
    let logo1 = UILabel()
    let logo2 = UILabel()
    let globeLogo = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    //backgroundColor = Colors.clear
    backgroundColor = UIColor.blueColor()
    let boxSize: CGFloat = 100.0
    self.box = UIView(frame: CGRectMake(self.bounds.width / 2 - boxSize / 2,
        self.bounds.height / 2 - boxSize / 2,
        boxSize,
        boxSize))
    box.backgroundColor = Colors.clear
    self.addSubview(box)
    
    logo1.frame = CGRectMake((UIScreen.mainScreen().bounds.size.width / 2) - 100, UIScreen.mainScreen().bounds.size.height * 0.75, 100, 50)
    logo1.textAlignment = NSTextAlignment.Right
    logo1.textColor = UIColor.whiteColor()
    logo1.font = UIFont.boldSystemFontOfSize(25)
    logo1.alpha = 0
    logo1.text = "Geo "
    self.addSubview(logo1)
    
    logo2.frame = CGRectMake(logo1.frame.maxX, UIScreen.mainScreen().bounds.size.height * 0.75, 100, 50)
    logo2.textAlignment = NSTextAlignment.Left
    logo2.textColor = UIColor.whiteColor()
    logo2.font = UIFont.boldSystemFontOfSize(25)
    logo2.alpha = 0
    logo2.text = "Feud"
    self.addSubview(logo2)
    

    
    
    let orgLogo1Center = logo1.center
    let orgLogo2Center = logo2.center
    
    logo1.transform = CGAffineTransformScale(logo1.transform, 0.1, 0.1)
    logo2.transform = CGAffineTransformScale(logo2.transform, 0.1, 0.1)
    
    logo1.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
    logo2.center = logo1.center
    
    UIView.animateWithDuration(0.35, animations: { () -> Void in
        self.logo1.transform = CGAffineTransformIdentity
        self.logo1.alpha = 1
        self.logo1.center = orgLogo1Center
        }, completion: { (value: Bool) in
            UIView.animateWithDuration(0.35, animations: { () -> Void in
                self.logo2.transform = CGAffineTransformIdentity
                self.logo2.alpha = 1
                self.logo2.center = orgLogo2Center
            })
            
    })
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }


  func startAnimation() {

    box.layer.anchorPoint = CGPointMake(0.5, 0.6)



    NSTimer.scheduledTimerWithTimeInterval(0.45, target: self,
      selector: "drawRedAnimatedRectangle",
      userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(0.65, target: self,
      selector: "drawBlueAnimatedRectangle",
      userInfo: nil, repeats: false)
  }

  func drawRedAnimatedRectangle() {
    box.layer.addSublayer(redRectangleLayer)
    redRectangleLayer.animateStrokeWithColor(Colors.red)
  }

  func drawBlueAnimatedRectangle() {
    box.layer.addSublayer(blueRectangleLayer)
    blueRectangleLayer.animateStrokeWithColor(Colors.white)
    
    

    
    NSTimer.scheduledTimerWithTimeInterval(0.40, target: self, selector: "drawArc",
      userInfo: nil, repeats: false)
  }

  func drawArc() {
    box.layer.addSublayer(arcLayer)
    arcLayer.animate()
    
    globeLogo.textAlignment = NSTextAlignment.Right
    globeLogo.font = UIFont.boldSystemFontOfSize(40)
    globeLogo.text = ""
    globeLogo.frame = CGRectMake(0, 0, 100, 50)
    globeLogo.center = CGPointMake(box.bounds.width / 2, box.bounds.height / 2)
    globeLogo.frame.offsetInPlace(dx: 0, dy: 5)
    globeLogo.transform = CGAffineTransformScale(globeLogo.transform, 0.45, 0.5)
    
    let dLabel = UILabel(frame: CGRectMake(0, 0, 50, 50))
    dLabel.center = CGPointMake(box.bounds.width / 2, box.bounds.height / 2)
    dLabel.textColor = UIColor.blueColor()
    dLabel.textAlignment = NSTextAlignment.Center
    dLabel.font = UIFont.boldSystemFontOfSize(40)
    dLabel.text = "D"
    
    let dLabel2 = UILabel(frame: CGRectMake(0, 0, 100, 50))
    dLabel2.center = CGPointMake(box.bounds.width / 2, box.bounds.height / 2)
    dLabel2.frame.offsetInPlace(dx: 10, dy: 10)
    dLabel2.textColor = UIColor.blueColor()
    dLabel2.textAlignment = NSTextAlignment.Center
    dLabel2.font = UIFont.boldSystemFontOfSize(40)
    dLabel2.text = "D"
    box.addSubview(globeLogo)
    box.addSubview(dLabel)
    box.addSubview(dLabel2)


    
    NSTimer.scheduledTimerWithTimeInterval(0.90, target: self, selector: "expandView",
      userInfo: nil, repeats: false)
  }

  func expandView() {
    

    
    box.backgroundColor = Colors.white
    frame = CGRectMake(frame.origin.x - blueRectangleLayer.lineWidth,
      frame.origin.y - blueRectangleLayer.lineWidth,
      frame.size.width + blueRectangleLayer.lineWidth * 2,
      frame.size.height + blueRectangleLayer.lineWidth * 2)
    box.layer.sublayers = nil

    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
      self.box.frame = self.bounds
      }, completion: { finished in
        self.redRectangleLayer.removeAllAnimations()
        self.redRectangleLayer.removeFromSuperlayer()
        self.blueRectangleLayer.removeAllAnimations()
        self.blueRectangleLayer.removeFromSuperlayer()
        
        self.arcLayer.removeAllAnimations()
        self.arcLayer.removeFromSuperlayer()
        self.finishedAnimating()
    })
  }

  func finishedAnimating() {
    delegate?.loadScreenFinished()
  }



}
