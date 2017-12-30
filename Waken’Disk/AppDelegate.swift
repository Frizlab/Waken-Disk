/*
 * AppDelegate.swift
 * Waken’Disk
 *
 * Created by François LAMBOLEY on 28/07/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Cocoa



@NSApplicationMain
class AppDelegate : NSObject, NSApplicationDelegate {
	
	@IBOutlet weak var window: NSWindow!
	
	@objc dynamic var volumeMountsObserver: VolumeMountsObserver! = nil
	
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		volumeMountsObserver = VolumeMountsObserver(treatNonRemovable: true)
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
}
