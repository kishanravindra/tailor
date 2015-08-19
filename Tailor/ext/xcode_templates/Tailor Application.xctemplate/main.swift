import Tailor
NSLog("Hi! There are a few more things you'll need to do before your application is ready.")
NSLog("1. Open __PACKAGENAME__Configuration.swift and set the sessionEncryptionKey to " + AesEncryptor.generateKey())
NSLog("2. Remove the files called DeleteThisFile in the models and controllers directories")
NSLog("3. Remove these log lines from main.swift")
Application.start()