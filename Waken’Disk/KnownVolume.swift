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
 * However, there won't be any uniquing: If two different known volumes are
 * inited with the same volume, two different known volumes will be returned and
 * they won't be synchronized. */
class KnownVolume : NSObject {
	
	let canBeSaved: Bool
	dynamic let volume: Volume
	dynamic var automaticallyKeptAwoken: Bool {
		didSet {
			saveVolumeSetting(automaticallyKeptAwoken as AnyObject, forKey: "keptAwoken")
		}
	}
	
	dynamic var keptAwoken: Bool {
		return timer != nil
	}
	
	dynamic var keepAwokenButtonTitle: String {
		return !keptAwoken ? "Keep Awoken" : "Stop Awaking"
	}
	
	dynamic var infoText: String
	
	private var timer: Timer?
	
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
	
	@IBAction func toggleWakingUp(_ sender: AnyObject?) {
		if keptAwoken { stopWakingUp()}
		else          {startWakingUp()}
	}
	
	func startWakingUp() {
		if timer == nil {
			callKVOForKeptAwokenValueChange(true)
			timer = Timer.scheduledTimer(timeInterval: 42.0, target: self, selector: #selector(KnownVolume.wakeItUp(_:)), userInfo: nil, repeats: true)
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
	
	private func callKVOForKeptAwokenValueChange(_ willChange: Bool) {
		var keys = ["keptAwoken", "keepAwokenButtonTitle"]
		if willChange {keys = Array(keys.reversed())}
		for key in keys {
			if willChange {willChangeValue(forKey: key)}
			else          { didChangeValue(forKey: key)}
		}
	}
	
	@objc
	private func wakeItUp(_ t: Timer?) {
//		print("Waking up volume \(volume)")
		
		let basePath = volume.url.path
		var filename: String
		repeat {
			filename = (basePath as NSString).appendingPathComponent(".awake.\(arc4random())")
		} while FileManager.default.fileExists(atPath: filename)
		
		let fm = FileManager.default
		let created = fm.createFile(atPath: filename, contents: nil, attributes: nil)
		let _ = try? fm.removeItem(atPath: filename)
		infoText = (created ? keptAwokenText : keptAwokenWriteFailText)
	}
	
	private func getSavedVolumeSettingWithKey(_ key: String) -> AnyObject? {
		if let volUUID = volume.volumeUUID {
			if let savedVolume = UserDefaults.standard.object(forKey: volUUID) as? [String: AnyObject] {
				return savedVolume[key]
			}
		}
		
		return nil
	}
	
	private func saveVolumeSetting(_ value: AnyObject, forKey key: String) {
		if let volUUID = volume.volumeUUID {
			let ud = UserDefaults.standard
			
			var savedVolume = [String: AnyObject]()
			if let curSavedVolume = ud.object(forKey: volUUID) as? [String: AnyObject] {
				savedVolume = curSavedVolume
			}
			
			savedVolume[key] = value
			ud.set(NSDictionary(dictionary: savedVolume), forKey: volUUID)
		}
	}
	
}
