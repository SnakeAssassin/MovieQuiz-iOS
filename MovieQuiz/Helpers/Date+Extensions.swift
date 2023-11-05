import Foundation

private let dateTimeDefaultFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    
    dateFormatter.dateFormat = "dd.MM.YY hh:mm"
    
    return dateFormatter
}()

extension Date {
    var dateTimeString: String { dateTimeDefaultFormatter.string(from: self) }
}
