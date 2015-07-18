import Foundation

public class MedicineStats : CoreDataContextManager{
    let medicine: Medicine
    
    init(context: NSManagedObjectContext, medicine: Medicine){
        self.medicine = medicine
        super.init(context: context)
    }
    
    /// Returns the number of pills taken between two dates
    ///
    /// :param: `NSDate optional`: first date (by default is NSDate.min)
    /// :param: `NSDate optional`: second date (by default is NSDate.max)
    /// :returns: `Int`: Number of pills
    public func numberPillsTaken(date1: NSDate = NSDate.min, date2: NSDate = NSDate.max) -> Int{
        var count = 0
        for r in medicine.registriesManager(context).getRegistries(date1: date1, date2: date2){
            if (r.tookMedicine){
                count++
            }
        }
        
        return count
    }
    
    /// Returns the number of pills that the user should have taken between two dates
    ///
    /// :param: `NSDate optional`: first date (by default is NSDate.min)
    /// :param: `NSDate optional`: second date (by default is NSDate.max)
    /// :returns: `Int`: Number of supposed pills
    public func numberSupposedPills(date1: NSDate = NSDate.min, date2: NSDate = NSDate.max) -> Int{
        if (medicine.registriesManager(context).getRegistries(date1: date1, date2: date2).count == 0){
            return 0
        }
        
        if date1 > date2 {
            return numberSupposedPills(date1: date2, date2: date1)
        }
        
        var d1: NSDate = date1
        if NSDate.areDatesSameDay(d1, dateTwo: NSDate.min) {
            d1 = medicine.registriesManager(context).oldestEntry()!.date
        }
        
        var d2: NSDate = date2
        if NSDate.areDatesSameDay(d2, dateTwo: NSDate.max) {
            d2 = medicine.registriesManager(context).mostRecentEntry()!.date
        }
        
        //+1 to include d1
        let numDays = (d2 - d1) + 1
        
        return  medicine.isDaily() ?  numDays : Int(ceil(Float(numDays)/7))
    }
    
    /// Returns the number of pills that the user should have taken between two dates
    ///
    //// Adherence = numberPillsTaken/SupposedPills
    ///
    /// :param: `NSDate optional`: first date (by default is NSDate.min)
    /// :param: `NSDate optional`: second date (by default is NSDate.max)
    /// :returns: `Float`: Pill adherence
    public func pillAdherence(date1: NSDate = NSDate.min, date2: NSDate = NSDate.max) -> Float{
        let supposedPills = numberSupposedPills(date1: date1, date2: date2)
        
        if(supposedPills == 0){
            return 1.0
        }
        
        let pillsTaken = numberPillsTaken(date1: date1, date2: date2)
        
        return Float(pillsTaken)/(Float(supposedPills))
    }
    
    /// Returns the current Pill Streak of the user.
    ///
    /// If the user misses a day, the streak will be reset to 0
    ///
    /// :param: `NSDate optional`: first date (by default is NSDate.min)
    /// :param: `NSDate optional`: second date (by default is NSDate.max)
    /// :returns: `Int`: Pill streak
    public func pillStreak(date1: NSDate = NSDate.min, date2: NSDate = NSDate.max) -> Int{
        var result = 0
        
        let isDaily = medicine.isDaily()
        var previousDate: NSDate?
        for r in medicine.registriesManager(context).getRegistries(date1: date1, date2: date2, mostRecentFirst: true){
            //check for missing entries
            if let previousD = previousDate{
                if (isDaily && !NSDate.areDatesSameDay(previousD - 1.day, dateTwo: r.date)) ||
                    (!isDaily && !NSDate.areDatesSameWeek(previousD - 7.day, dateTwo: r.date))
                {
                    return result
                }
            }
            
            if r.tookMedicine{
                result += 1
            }else{
                return result
            }
            
            previousDate = r.date
        }
        
        return result
    }
}