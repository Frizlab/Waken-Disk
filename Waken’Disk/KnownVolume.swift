/*
 * KnownVolume.swift
 * Waken’Disk
 *
 * Created by François Lamboley on 9/17/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Cocoa



/* When initializing a known volume, if the volume has already been saved, the
 * value of keepAwaken will be retrieved.
 * However, there won't be any uniquing: if two different known volumes are
 * inited with the same volume, two different known volumes will be returned and
 * they won't be synchronized.
 * Moreover, to know if a volume has been saved, the URL of the volume will be
 * used. So if two volumes are mounted at different point of the time with the
 * same name they will be recognized as the same volume. */
class KnownVolume: NSObject {
	let canBeSaved: Bool
	dynamic let volume: Volume
	dynamic var automaticallyKeptAwoken: Bool {
		didSet {
			saveVolumeSetting(automaticallyKeptAwoken, forKey: "keptAwoken")
		}
	}
	
	dynamic var keptAwoken: Bool {
		return timer != nil
	}
	
	private var timer: NSTimer?
	
	init(volume v: Volume) {
		volume = v
		automaticallyKeptAwoken = false
		canBeSaved = (v.volumeUUID != nil)
		
		super.init()
		
		if let value = getSavedVolumeSettingWithKey("keptAwoken") as? NSNumber {
			automaticallyKeptAwoken = value.boolValue
		}
		
		if automaticallyKeptAwoken {
			startWakingUp()
		}
	}
	
	func startWakingUp() {
		if timer == nil {
			self.willChangeValueForKey("keptAwoken")
			timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("wakeItUp:"), userInfo: nil, repeats: true)
			self.didChangeValueForKey("keptAwoken")
		}
	}
	
	func stopWakingUp() {
		if timer != nil {
			self.willChangeValueForKey("keptAwoken")
			timer?.invalidate()
			timer = nil
			self.didChangeValueForKey("keptAwoken")
		}
	}
	
	@objc private func wakeItUp(t: NSTimer?) {
		var basePath = volume.url.path!
		var filename: String
		do {
			filename = basePath.stringByAppendingPathComponent(".awake.\(random())")
		} while NSFileManager.defaultManager().fileExistsAtPath(filename)
		
		NSFileManager.defaultManager().createFileAtPath(filename, contents: nil, attributes: nil)
		NSFileManager.defaultManager().removeItemAtPath(filename, error: nil)
	}
	
	private func getSavedVolumeSettingWithKey(key: String) -> AnyObject? {
		if let volUUID = volume.volumeUUID {
			if let savedVolume = NSUserDefaults.standardUserDefaults().objectForKey(volUUID) as? [String: AnyObject] {
				return savedVolume[key]
			}
		}
		return nil
	}
	
	private func saveVolumeSetting(value: AnyObject, forKey key: String) {
		if let volUUID = volume.volumeUUID {
			if let savedVolume = NSUserDefaults.standardUserDefaults().objectForKey(volUUID) as? [String: AnyObject] {
				automaticallyKeptAwoken = savedVolume["keptAwoken"]!.boolValue!
			}
		}
	}
}
