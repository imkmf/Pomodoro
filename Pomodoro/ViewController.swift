//
//  ViewController.swift
//  Pomodoro
//
//  Created by Kristian Freeman on 11/10/15.
//  Copyright © 2015 Kristian Freeman. All rights reserved.
//

import EventKit
import UIKit

class ViewController: UIViewController {
    var pomodoroItem: PomodoroItem!
    
    @IBOutlet weak var beginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        pomodoroItem = PomodoroItem(name: textField.text!)
        beginButton.hidden = false
        textField.resignFirstResponder()
        return true
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatusForEntityType(.Event) {
        case .Authorized:
            let event = EKEvent(eventStore: eventStore)
            event.title = "Pomodoro: " + pomodoroItem.name

            var calendar: EKCalendar!
            for cal in eventStore.calendarsForEntityType(.Event) {
                if cal.title == "Pomodoros" { calendar = cal }
            }
            event.calendar = calendar
            event.startDate = NSDate()
            event.endDate = NSDate(timeIntervalSinceNow: 1500)
            
            do {
                try eventStore.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                doDat()
            } catch {
                print("oh shit!")
            }
        case .Denied:
            print("Access denied")
        case .NotDetermined:
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                (accessGranted: Bool, error: NSError?) in
                
                if accessGranted == true {
                    dispatch_async(dispatch_get_main_queue(), {
                        eventStore.calendarsForEntityType(EKEntityType.Event)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                        UIApplication.sharedApplication().openURL(openSettingsUrl!)
                    })
                }
            })
        default:
            print("Case Default")
        }
    }
    
    func doDat() {
        NSTimer.scheduledTimerWithTimeInterval(1500, target: self, selector: "pomodoroDone", userInfo: nil, repeats: false)
    }
    
    func pomodoroDone() {
        createNotificationAndFire("Pomodoro finished")
        NSTimer.scheduledTimerWithTimeInterval(300, target: self, selector: "breakDone", userInfo: nil, repeats: false)
    }
    
    func breakDone() {
        createNotificationAndFire("Break done")
    }
    
    func createNotificationAndFire(title: String) {
        let notification = UILocalNotification()
        notification.alertBody = title
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}

