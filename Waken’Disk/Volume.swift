/*
 * Volume.swift
 * Waken’Disk
 *
 * Created by François LAMBOLEY on 19/08/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Cocoa



class Volume : NSObject {
	
	let url: URL
	
	let volumeUUID: String?
	let volumeName: String?
	let volumeIcon: NSImage?
	let isRemovable: Bool?
	
	init(url newURL: URL) {
		url = newURL
		
		/* Note: An alternate method of doing this would be to fetch one resource
		 *       value for each variable we want to set. That way, if for instance
		 *       fetching the volumeUUID fails, but not the volume name, we would
		 *       at least have the volume name.
		 *       That being said, it is highly probable that if fetching any
		 *       resource value fails, all of them would fail (doc says the
		 *       returned resource value might contain nil for some of the asked
		 *       values if they are not available, without the call failing). */
		let resourceValues = try? url.resourceValues(forKeys: [.volumeUUIDStringKey, .volumeNameKey, .volumeIsRemovableKey, .effectiveIconKey])
		volumeUUID = resourceValues?.volumeUUIDString
		volumeName = resourceValues?.volumeName
		volumeIcon = resourceValues?.effectiveIcon as? NSImage
		isRemovable = resourceValues?.volumeIsRemovable
	}
	
	override var description: String {
		return "{Volume URL: \(url); Volume Name: \(volumeName); Is Removable: \(isRemovable)}"
	}
	
}

func ==(lhs: Volume, rhs: Volume) -> Bool {
	return lhs.url == rhs.url
}
