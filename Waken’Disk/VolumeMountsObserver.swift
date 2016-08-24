/*
 * VolumeMountsObserver.swift
 * Waken’Disk
 *
 * Created by François LAMBOLEY on 19/08/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Cocoa



class VolumeMountsObserver : NSObject {
	
	let treatNonRemovable: Bool
	
	dynamic var mountedVolumes: [KnownVolume] = []
	
	init(treatNonRemovable: Bool) {
		self.treatNonRemovable = treatNonRemovable
		
		super.init()
		
		if let urls = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [URLResourceKey.volumeUUIDStringKey, URLResourceKey.volumeNameKey, URLResourceKey.volumeIsRemovableKey, URLResourceKey.effectiveIconKey], options: []) {
			for url in urls {
				_ = addVolume(Volume(url: url))
			}
		}
		
		/* Adding observer to notifications of mounted/unmounted volumes */
		NSWorkspace.shared().notificationCenter.addObserver(forName: NSNotification.Name.NSWorkspaceDidMount, object: nil, queue: OperationQueue.main) { (notif: Notification) -> Void in
			if let url = (notif as NSNotification).userInfo![NSWorkspaceVolumeURLKey] as? URL {
				_ = self.addVolume(Volume(url: url))
			}
		}
		NSWorkspace.shared().notificationCenter.addObserver(forName: NSNotification.Name.NSWorkspaceDidUnmount, object: nil, queue: OperationQueue.main) { (notif: Notification) -> Void in
			if let url = (notif as NSNotification).userInfo![NSWorkspaceVolumeURLKey] as? URL {
				_ = self.removeVolume(Volume(url: url))
			}
		}
	}
	
	private func addVolume(_ volume: Volume) -> Bool {
		print("Asked to add volume \(volume)... ", terminator: "")
		
		if (!treatNonRemovable && volume.isRemovable != nil && !volume.isRemovable!) || indexOfVolume(volume) != nil {
			print("Not done")
			return false
		}
		
		mountedVolumes.append(KnownVolume(volume: volume))
		mountedVolumes.sort { (a, b) -> Bool in
			if a.volume.volumeUUID != nil && b.volume.volumeUUID == nil {return true}
			if a.volume.volumeUUID == nil && b.volume.volumeUUID != nil {return false}
			switch (a.volume.volumeName, b.volume.volumeName) {
			case let (vna?, vnb?): return vna < vnb
			case     (_?, nil):    return true
			default:               return false
			}
		}
		print("Done")
		return true
	}
	
	private func removeVolume(_ volume: Volume) -> Bool {
		print("Asked to remove volume \(volume)... ", terminator: "")
		
		guard let idx = indexOfVolume(volume) else {
			print("Not done")
			return false
		}
		
		mountedVolumes.remove(at: idx)
		print("Done")
		return true
	}
	
	private func indexOfVolume(_ volume: Volume) -> Int? {
		return mountedVolumes.index {$0.volume == volume}
	}
	
}
