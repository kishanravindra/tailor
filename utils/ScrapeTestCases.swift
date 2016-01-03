#! swift
import Glibc
import Foundation

func scrapeFile(filename: String) {
	print("Scraping test cases from \(filename)")
	let cFilename = filename.bridge().cStringUsingEncoding(NSUTF8StringEncoding)
	let fileDescriptor = open(cFilename, O_RDONLY)
	guard fileDescriptor > 0 else {
		print("Could not open file")
		exit(1)
	} 
	defer { close(fileDescriptor) }

	let bufferSize = 1024
	let buffer = [UInt8](count: bufferSize, repeatedValue: 0)
	let bufferPointer = UnsafeMutablePointer<UInt8>(buffer)
	let fileData = NSMutableData()
	repeat {
		let byteCount = read(fileDescriptor, bufferPointer, bufferSize)
		if byteCount == 0 {
			break
		}
		fileData.appendBytes(bufferPointer, length: byteCount)
	} while(true)
	guard let fileContents = NSString(data: fileData, encoding: NSUTF8StringEncoding) else {
		print("Could not read file; may not be UTF-8")
		exit(1)
	}

	for line in fileContents.componentsSeparatedByString("\n") {
		var line = line.bridge().stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
		if line.hasPrefix("func test") {
			let range = line.bridge().rangeOfString("(")
			if range.location != NSNotFound {
				let validRange = NSRange(location: 5, length: range.location - 5)
				line = line.bridge().substringWithRange(validRange)
			}
			print("      (\"\(line)\", \(line)),")
		}
	}
}

if Process.arguments.count < 2 {
	print("Please provide a filename")
	exit(1)
}
scrapeFile(Process.arguments[1])
