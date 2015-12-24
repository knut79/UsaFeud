
import Foundation
import UIKit

class OkButton: UIButton {
    
    var innerView:UILabel!
    var numberOfHints:UILabel!
    var orgFrame:CGRect!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, rightMargin:CGFloat,bottomMargin:CGFloat) {
        super.init(frame: frame)
        let label = UILabel(frame: CGRectMake(0, 0, frame.width - rightMargin, frame.height - bottomMargin))
        label.text = "🆗"
        label.textAlignment = NSTextAlignment.Center
        label.layer.borderColor = UIColor.lightGrayColor().CGColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = label.bounds.size.width / 2
        label.layer.masksToBounds = true
        self.addSubview(label)

    }
    
    
    func isVisible() -> Bool
    {
        return self.frame == orgFrame
    }
    
    func hide(hide:Bool = true)
    {
        if hide 
        {
            if isVisible()
            {
                self.center = CGPointMake(UIScreen.mainScreen().bounds.maxX + self.frame.width, self.center.y)
            }
        }
        else
        {
            self.frame = self.orgFrame
        }
    }
}
