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
	
	
	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(NSWorkspaceDidMountNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification!) -> Void in
			println("Mounted disk URL: \(notif.userInfo[NSWorkspaceVolumeURLKey])")
		}
		NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(NSWorkspaceDidUnmountNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification!) -> Void in
			println("Unmounted disk URL: \(notif.userInfo[NSWorkspaceVolumeURLKey])")
		}
		
		let urls = NSFileManager.defaultManager().mountedVolumeURLsIncludingResourceValuesForKeys([NSURLVolumeNameKey!, NSURLVolumeIsRemovableKey!], options: NSVolumeEnumerationOptions(0))
		for url in urls as [NSURL] {
			var volumeName_obj: AnyObject?
			var isRemovable_obj: AnyObject?
			url.getResourceValue(&volumeName_obj,  forKey: NSURLVolumeNameKey,        error: nil)
			url.getResourceValue(&isRemovable_obj, forKey: NSURLVolumeIsRemovableKey, error: nil)
			
			let volumeName = volumeName_obj as String
			let isRemovable = (isRemovable_obj as NSNumber).boolValue
			
			if isRemovable {
				println("Mounted URL: \(url), volume name: \(volumeName)")
			}
		}
	}
	
	func applicationWillTerminate(aNotification: NSNotification?) {
		// Insert code here to tear down your application
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication!) -> Bool {
		return true;
	}
}
