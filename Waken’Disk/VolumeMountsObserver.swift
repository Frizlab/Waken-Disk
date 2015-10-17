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
		
		if let urls = NSFileManager.defaultManager().mountedVolumeURLsIncludingResourceValuesForKeys([NSURLVolumeUUIDStringKey, NSURLVolumeNameKey, NSURLVolumeIsRemovableKey, NSURLEffectiveIconKey], options: []) {
			for url in urls {
				addVolume(Volume(URL: url))
			}
		}
		
		/* Adding observer to notifications of mounted/unmounted volumes */
		NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(NSWorkspaceDidMountNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification) -> Void in
			if let url = notif.userInfo![NSWorkspaceVolumeURLKey] as? NSURL {
				self.addVolume(Volume(URL: url))
			}
		}
		NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(NSWorkspaceDidUnmountNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification) -> Void in
			if let url = notif.userInfo![NSWorkspaceVolumeURLKey] as? NSURL {
				self.removeVolume(Volume(URL: url))
			}
		}
	}
	
	private func addVolume(volume: Volume) -> Bool {
		print("Asked to add volume \(volume)... ", terminator: "")
		
		if (!treatNonRemovable && volume.isRemovable != nil && !volume.isRemovable!) || indexOfVolume(volume) != NSNotFound {
			print("Not done")
			return false
		}
		
		mountedVolumes.append(KnownVolume(volume: volume))
		mountedVolumes.sortInPlace { (a, b) -> Bool in
			if a.volume.volumeUUID != nil && b.volume.volumeUUID == nil { return true }
			if a.volume.volumeUUID == nil && b.volume.volumeUUID != nil { return false }
			return a.volume.volumeName < b.volume.volumeName
		}
		print("Done")
		return true
	}
	
	private func removeVolume(volume: Volume) -> Bool {
		print("Asked to remove volume \(volume)... ", terminator: "")
		
		let idx = indexOfVolume(volume)
		if idx == NSNotFound {
			print("Not done")
			return false
		}
		
		mountedVolumes.removeAtIndex(idx)
		print("Done")
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
