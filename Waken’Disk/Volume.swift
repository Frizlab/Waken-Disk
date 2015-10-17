/*
 * Volume.swift
 * Waken’Disk
 *
 * Created by François LAMBOLEY on 19/08/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Cocoa



class Volume: NSObject {
	let url: NSURL
	
	let volumeUUID: String?
	let volumeName: String?
	let volumeIcon: NSImage?
	let isRemovable: Bool?
	
	init(URL: NSURL) {
		self.url = URL
		
		var volumeUUID_obj: AnyObject?
		var volumeIcon_obj: AnyObject?
		var volumeName_obj: AnyObject?
		var isRemovable_obj: AnyObject?
		let _ = try? self.url.getResourceValue(&volumeUUID_obj,  forKey: NSURLVolumeUUIDStringKey)
		let _ = try? self.url.getResourceValue(&volumeName_obj,  forKey: NSURLVolumeNameKey)
		let _ = try? self.url.getResourceValue(&isRemovable_obj, forKey: NSURLVolumeIsRemovableKey)
		let _ = try? self.url.getResourceValue(&volumeIcon_obj,  forKey: NSURLEffectiveIconKey)
		
		self.volumeUUID = volumeUUID_obj as? String
		self.volumeName = volumeName_obj as? String
		self.volumeIcon = volumeIcon_obj as? NSImage
		self.isRemovable = (isRemovable_obj as? NSNumber)?.boolValue
	}
	
	override var description: String {
		return "{Volume URL: \(url); Volume Name: \(volumeName); Is Removable: \(isRemovable)}"
	}
}

func ==(lhs: Volume, rhs: Volume) -> Bool {
	return lhs.url.isEqual(rhs.url)
}
