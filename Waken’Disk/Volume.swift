/*
 * Volume.swift
 * Waken’Disk
 *
 * Created by François LAMBOLEY on 19/08/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Cocoa



class Volume: NSObject, Equatable, Printable {
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
		self.url.getResourceValue(&volumeUUID_obj,  forKey: NSURLVolumeUUIDStringKey,  error: nil)
		self.url.getResourceValue(&volumeName_obj,  forKey: NSURLVolumeNameKey,        error: nil)
		self.url.getResourceValue(&isRemovable_obj, forKey: NSURLVolumeIsRemovableKey, error: nil)
		self.url.getResourceValue(&volumeIcon_obj,  forKey: NSURLEffectiveIconKey,     error: nil)
		
		self.volumeUUID = volumeUUID_obj as? String
		self.volumeName = volumeName_obj as? String
		self.volumeIcon = volumeIcon_obj as? NSImage
		if isRemovable_obj != nil { self.isRemovable = (isRemovable_obj as NSNumber).boolValue }
		else                      { self.isRemovable = nil }
	}
	
	override var description: String {
		return "{Volume URL: \(url); Volume Name: \(volumeName); Is Removable: \(isRemovable)}"
	}
}

func ==(lhs: Volume, rhs: Volume) -> Bool {
	return lhs.url.isEqual(rhs.url)
}
