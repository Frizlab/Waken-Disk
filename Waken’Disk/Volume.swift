/*
 * Volume.swift
 * Waken’Disk
 *
 * Created by François LAMBOLEY on 19/08/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Foundation



class Volume: NSObject, Equatable, Printable {
	let url: NSURL
	
	let volumeName: String?
	let isRemovable: Bool?
	
	init(URL: NSURL) {
		self.url = URL
		
		var volumeName_obj: AnyObject?
		var isRemovable_obj: AnyObject?
		self.url.getResourceValue(&volumeName_obj,  forKey: NSURLVolumeNameKey,        error: nil)
		self.url.getResourceValue(&isRemovable_obj, forKey: NSURLVolumeIsRemovableKey, error: nil)
		
		self.volumeName = volumeName_obj as? String
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
