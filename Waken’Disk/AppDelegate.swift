/*
 * AppDelegate.swift
 * Waken’Disk
 *
 * Created by François LAMBOLEY on 28/07/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Cocoa



class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!
	
	dynamic var volumeMountsObserver: VolumeMountsObserver! = nil
	
	
	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		volumeMountsObserver = VolumeMountsObserver(treatNonRemovable: true)
	}
	
	func applicationWillTerminate(aNotification: NSNotification?) {
		// Insert code here to tear down your application
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication!) -> Bool {
		return true
	}
}
