import UIKit

/// Если в Assets есть цвет с названием "YP Black", то он присвоится переменной ypBlack. Если в Assets нет цвета с таким названием, с помощью синтаксиса ?? укажите дефолтное значение. В таком случае будет присвоен предзаданный цвет UIColor.black.
extension UIColor {
        static var ypGreen: UIColor { UIColor(named: "YP Green") ?? UIColor.green }
        static var ypRed: UIColor { UIColor(named: "YP Red") ?? UIColor.red }
        static var ypBlack: UIColor { UIColor(named: "YP Black") ?? UIColor.black}
        static var ypBackground: UIColor { UIColor(named: "YP Background") ?? UIColor.darkGray }
        static var ypGray: UIColor { UIColor(named: "YP Gray") ?? UIColor.gray }
        static var ypWhite: UIColor { UIColor(named: "YP White") ?? UIColor.white}
     }
