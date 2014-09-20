/*
 * VolumeMountsObserver.swift
 * Waken’Disk
 *
 * Created by François LAMBOLEY on 19/08/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Cocoa



class VolumeMountsObserver: NSObject {
	let treatNonRemovable: Bool
	
	dynamic var mountedVolumes: [KnownVolume] = []
	
	init(treatNonRemovable: Bool) {
		self.treatNonRemovable = treatNonRemovable
		
		super.init()
		
		let urls = NSFileManager.defaultManager().mountedVolumeURLsIncludingResourceValuesForKeys([NSURLVolumeUUIDStringKey!, NSURLVolumeNameKey!, NSURLVolumeIsRemovableKey!, NSURLEffectiveIconKey!], options: NSVolumeEnumerationOptions(0))
		for url in urls as [NSURL] {
			addVolume(Volume(URL: url))
		}
		
		/* Adding observer to notifications of mounted/unmounted volumes */
		NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(NSWorkspaceDidMountNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification!) -> Void in
			self.addVolume(Volume(URL: notif.userInfo![NSWorkspaceVolumeURLKey] as NSURL))
			return ()
		}
		NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(NSWorkspaceDidUnmountNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification!) -> Void in
			self.removeVolume(Volume(URL: notif.userInfo![NSWorkspaceVolumeURLKey] as NSURL))
			return ()
		}
	}
	
	private func addVolume(volume: Volume) -> Bool {
		print("Asked to add volume \(volume)... ")
		
		if (!treatNonRemovable && volume.isRemovable != nil && !volume.isRemovable!) || indexOfVolume(volume) != NSNotFound {
			println("Not done")
			return false
		}
		
		mountedVolumes.append(KnownVolume(volume: volume))
		println("Done")
		return true
	}
	
	private func removeVolume(volume: Volume) -> Bool {
		print("Asked to remove volume \(volume)... ")
		
		let idx = indexOfVolume(volume)
		if idx == NSNotFound {
			println("Not done")
			return false
		}
		
		mountedVolumes.removeAtIndex(idx)
		println("Done")
		return true
	}
	
	private func indexOfVolume(volume: Volume) -> Int {
		for i in 0..<mountedVolumes.count {
			if volume == mountedVolumes[i].volume {
				return i
			}
		}
		return NSNotFound
	}
}
