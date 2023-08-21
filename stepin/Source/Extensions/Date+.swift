import Foundation
public enum dateCompareType{
    case future
    case past
    case current
}
extension Date {
    static func getCurrentYear() -> String{
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
    static func getCurrentMonth() -> String{
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
    static func getCurrentDay() -> String{
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
    public func dateCompare(fromDate: Date) -> dateCompareType {
        var strDateMessage:dateCompareType = .current
        let result: ComparisonResult = self.compare(fromDate)
        print(fromDate, self)
        switch result {
        case .orderedAscending:
            strDateMessage = .future
            break
        case .orderedDescending:
            strDateMessage = .past
            break
        case .orderedSame:
            strDateMessage = .current
            break
        default:
            break
        }
        return strDateMessage
    }
    
    func converToTime(str: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        let date = dateFormatter.date(from: str)
        return (date ?? Date()).toString(dateFormat: "MMM dd")
    }
    
    
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
    
    func convertGMTTime(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let dateStr = dateFormatter.string(from: date)
        return dateStr
    }
    func convertStringToTimeStamp(date: String) -> Int {
        if date == "" {return 0}
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let convertDate = dateFormatter.date(from: date)
        let convertTimeStamp = Int(convertDate!.timeIntervalSince1970) + 32400 //이거 해당 유저 시간대별로 나누어줄 필요가 있을듯
        return convertTimeStamp
    }
    func convertTimeStamp(date: Int) -> String {
        let currentDate = Date().timeIntervalSince1970
        //댓글 올린 시간으로 부터 지난 시간
        let differenceDay = Int(currentDate) - date
        
        if (differenceDay / 60) == 0 {
            return "Just now"
        }
        
        //1시간 이전은 분 단위
        if (differenceDay / 3600) < 1 {
            if differenceDay / 60 == 1 {
                return "\(differenceDay / 60) min ago"
            } else {
                return "\(differenceDay / 60) mins ago"
            }
        }
        //1시간보다 크고, 24시간 보다는 작을때는 시 단위
        else if (differenceDay / 3600) < 24 && (differenceDay / 3600) >= 1 {
            if differenceDay / 3600 == 1 {
                return "\(differenceDay / 3600) hr ago"
            } else {
                return "\(differenceDay / 3600) hrs ago"
            }
        }
        //7일보단 적지만 1일보다 크면 일단위
        else if (differenceDay / 86400) < 7 && (differenceDay / 86400) >= 1 {
            if differenceDay / 86400 == 1 {
                return "\(differenceDay / 86400) day ago"
            } else {
                return "\(differenceDay / 86400) days ago"
            }
        }
        //7일보다 크지만 28일보다 작으면 주단위
        else if (differenceDay / 86400) < 28 && (differenceDay / 86400) >= 7 {
            if differenceDay / 604800 == 1 {
                return "\(differenceDay / 604800) week ago"
            } else {
                return "\(differenceDay / 604800) weeks ago"
            }
        }
        //한달이상을 경우 long time ago
        else {
            return "long time ago"
        }
    }
    func convertTimeStampToMinuite(date: Int) -> Int {
        let currentDate = Date().timeIntervalSince1970
        let differenceDate = Int(currentDate) - date
        
        return differenceDate / 60
    }
}
