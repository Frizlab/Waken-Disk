/*
 * KnownVolume.swift
 * Waken’Disk
 *
 * Created by François Lamboley on 9/17/14.
 * Copyright (c) 2014 Frizlab. All rights reserved.
 */

import Cocoa

let notKeptAwokenText = "Not kept awoken"
let keptAwokenText = "Kept awoken"
let keptAwokenWriteFailText = "Kept awoken, last write failed"

// 😴😎

/* When initializing a known volume, if the volume has already been saved, the
 * value of keepAwaken will be retrieved.
 * However, there won't be any uniquing: if two different known volumes are
 * inited with the same volume, two different known volumes will be returned and
 * they won't be synchronized. */
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
	
	dynamic var keepAwokenButtonTitle: String {
		return !keptAwoken ? "Keep Awoken" : "Stop Awaking"
	}
	
	dynamic var infoText: String
	
	private var timer: NSTimer?
	
	init(volume v: Volume) {
		volume = v
		infoText = notKeptAwokenText
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
	
	@IBAction func toggleWakingUp(sender: AnyObject?) {
		if keptAwoken {  stopWakingUp() }
		else          { startWakingUp() }
	}
	
	func startWakingUp() {
		if timer == nil {
			callKVOForKeptAwokenValueChange(true)
			timer = NSTimer.scheduledTimerWithTimeInterval(42.0, target: self, selector: Selector("wakeItUp:"), userInfo: nil, repeats: true)
			callKVOForKeptAwokenValueChange(false)
		}
		infoText = keptAwokenText
	}
	
	func stopWakingUp() {
		if timer != nil {
			callKVOForKeptAwokenValueChange(true)
			timer?.invalidate()
			timer = nil
			callKVOForKeptAwokenValueChange(false)
		}
		infoText = notKeptAwokenText
	}
	
	private func callKVOForKeptAwokenValueChange(willChange: Bool) {
		var keys = ["keptAwoken", "keepAwokenButtonTitle"]
		if willChange { keys = Array(keys.reverse()) }
		for key in keys {
			if willChange { willChangeValueForKey(key) }
			else          {  didChangeValueForKey(key) }
		}
	}
	
	@objc private func wakeItUp(t: NSTimer?) {
		let basePath = volume.url.path!
		var filename: String
		repeat {
			filename = (basePath as NSString).stringByAppendingPathComponent(".awake.\(random())")
		} while NSFileManager.defaultManager().fileExistsAtPath(filename)
		
		let fm = NSFileManager.defaultManager()
		let created = fm.createFileAtPath(filename, contents: nil, attributes: nil)
		let _ = try? fm.removeItemAtPath(filename)
		infoText = (created ? keptAwokenText : keptAwokenWriteFailText)
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
			let ud = NSUserDefaults.standardUserDefaults()
			
			var savedVolume = [String: AnyObject]()
			if let curSavedVolume = ud.objectForKey(volUUID) as? [String: AnyObject] {
				savedVolume = curSavedVolume
			}
			
			savedVolume[key] = value
			ud.setObject(NSDictionary(dictionary: savedVolume), forKey: volUUID)
		}
	}
}
