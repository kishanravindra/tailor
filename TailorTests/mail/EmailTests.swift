@testable import Tailor
import TailorTesting
import XCTest

class EmailTests: XCTestCase, TailorTestable {
  struct TestTemplate: TemplateType {
    var state: TemplateState
    
    init(state: TemplateState) {
      self.state = state
    }
    init() {
      self.init(state: TemplateState(EmptyController()))
    }
    
    mutating func body() {
      tag("p") { text("Hello") }
    }
  }
  
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testInitializeSetsFields() {
    let attachment = Email.Attachment(type: "image/jpeg", filename: "image.jpg", data: NSData(bytes: [1,2,3,4]))
    let email = Email(
      from: "test1@johnbrownlee.com",
      recipients: ["test2@johnbrownlee.com", "test3@johnbrownlee.com"],
      ccs: ["test4@johnbrownlee.com", "test5@johnbrownlee.com"],
      bccs: ["test6@johnbrownlee.com", "test7@johnbrownlee.com"],
      subject: "Yo",
      body: "Yo dawg",
      attachments: [attachment]
    )
    assert(email.sender, equals: "test1@johnbrownlee.com")
    assert(email.recipients, equals: ["test2@johnbrownlee.com","test3@johnbrownlee.com"])
    assert(email.ccs, equals: ["test4@johnbrownlee.com","test5@johnbrownlee.com"])
    assert(email.bccs, equals: ["test6@johnbrownlee.com","test7@johnbrownlee.com"])
    assert(email.subject, equals: "Yo")
    assert(email.body, equals: "Yo dawg")
    assert(email.attachments, equals: [attachment])
  }
  
  func testInitializeWithSingleRecipientSetsRecipients() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    assert(email.recipients, equals: ["test2@johnbrownlee.com"])
  }
  
  func testInitializeWithRecipientListAndSingleRecipientSetsAllRecipients() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", recipients: ["test3@johnbrownlee.com", "test4@johnbrownlee.com"], subject: "Yo", body: "Yo dawg")
    assert(email.recipients, equals: ["test2@johnbrownlee.com","test3@johnbrownlee.com","test4@johnbrownlee.com"])
  }
  
  func testInitializeWithEmptyRecipientListSetsNoRecipients() {
    let email = Email(from: "test1@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    assert(email.recipients, equals: [])
  }
  
  func testInitializeWithTemplateUsesTemplateBody() {
    let template = TestTemplate()
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", template: template)
    assert(email.body, equals: "<p>Hello</p>")
  }
  
  
  func testInitializeWithTemplateSetsTemplateOnEmail() {
    let template = TestTemplate()
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", template: template)
    assert(email, renderedTemplate: TestTemplate.self)
  }
  
  func testAllRecipientsIncludesRecipientsCcsAndBccs() {
    let email = Email(from: "test1@johnbrownlee.com", recipients: ["test2@johnbrownlee.com", "test3@johnbrownlee.com"], ccs: ["test4@johnbrownlee.com", "test5@johnbrownlee.com"], bccs: ["test6@johnbrownlee.com", "test7@johnbrownlee.com"], subject: "Yo", body: "Yo dawg")
    assert(email.allRecipients, equals: ["test2@johnbrownlee.com","test3@johnbrownlee.com","test4@johnbrownlee.com","test5@johnbrownlee.com","test6@johnbrownlee.com","test7@johnbrownlee.com"])
  }
  
  func testInitializeAttachmentSetsFields() {
    let data = NSData(bytes: [1,2,3,4])
    let attachment = Email.Attachment(type: "image/jpeg", filename: "profile.jpg", data: data)
    assert(attachment.type, equals: "image/jpeg")
    assert(attachment.filename, equals: "profile.jpg")
    assert(attachment.data, equals: data)
  }
  
  func testFullMessageContainsHeadersAndBody() {
    let email = Email(from: "test1@johnbrownlee.com", recipients: ["test2@johnbrownlee.com","test3@johnbrownlee.com"], subject: "Yo", body: "Yo dawg")
    let date = Timestamp.now().format(TimeFormat.Rfc2822)
    let messageData = email.fullMessage
    let message = NSString(data: messageData, encoding: NSASCIIStringEncoding) as? String ?? ""
    assert(message, equals:
      "From: test1@johnbrownlee.com\r\n" +
        "To: test2@johnbrownlee.com,test3@johnbrownlee.com\r\n" +
        "Date: \(date)\r\n" +
        "Subject: Yo\r\n" +
        "Content-Type: text/html; charset=UTF-8\r\n" +
        "Content-Transfer-Encoding: quoted-printable\r\n" +
        "\r\n" +
        email.body
    )
  }
  
  func testFullMessageIncludesCcHeader() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com",ccs: ["test3@johnbrownlee.com", "test4@johnbrownlee.com"], subject: "Yo", body: "Yo dawg")
    
    let messageData = email.fullMessage
    let message = NSString(data: messageData, encoding: NSASCIIStringEncoding) as? String ?? ""
    assert(message, contains: "CC: test3@johnbrownlee.com,test4@johnbrownlee.com\r\n")
  }
  
  func testFullMessageDoesNotIncludesBccHeader() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", bccs: ["test3@johnbrownlee.com", "test4@johnbrownlee.com"], subject: "Yo", body: "Yo dawg")
    
    let messageData = email.fullMessage
    let message = NSString(data: messageData, encoding: NSASCIIStringEncoding) as? String ?? ""
    assert(!message.contains("test3@johnbrownlee.com"))
    assert(!message.contains("test4@johnbrownlee.com"))
  }
  
  func testFullMessageEncodesNonAsciiCharactersInBody() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Olé All")
    let message = NSString(data: email.fullMessage, encoding: NSASCIIStringEncoding) as! String
    assert(message, contains: "Ol=C3=A9 All")
  }
  
  func testFullMessageEncodesSpecialCharactersInSubject() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Olé\n Friends?", body: "Yo")
    let message = NSString(data: email.fullMessage, encoding: NSASCIIStringEncoding) as! String
    assert(message, contains: "Subject: =?UTF-8?Q?Ol=C3=A9=0A=20Friends=3F?=")
  }
  
  func testFullMessageEncodesAndWrapsLongSubject() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Urgent Action Required On This Limited-Time Opportunity For You asd;lkjfasd;fkljasdasdfkjsadfkjlasdf asdlkfjasldkfjlaksjdfkljasdfkljas adfsl;kjasdfl;kjadsfl;kjasdfkl;jasd;fkljasdf;lkjasdfl;kjasdf;lkjasdf;lkjasdfkl;jasdfkl;jasdfkl;jasdf", body: "Yo")
    let message = NSString(data: email.fullMessage, encoding: NSASCIIStringEncoding) as! String
    
    assert(message, contains: "Subject: =?UTF-8?Q?Urgent=20Action=20Required=20On=20This=20Limited-Time?=\r\n =?UTF-8?Q?=20Opportunity=20For=20You=20asd;lkjfasd;fkljasdasdfkjsadfkjlas?=\r\n =?UTF-8?Q?df=20asdlkfjasldkfjlaksjdfkljasdfkljas=20adfsl;kjasdfl;kjadsfl;?=\r\n =?UTF-8?Q?kjasdfkl;jasd;fkljasdf;lkjasdfl;kjasdf;lkjasdf;lkjasdfkl;jasdfk?=\r\n =?UTF-8?Q?l;jasdfkl;jasdf?=")
  }

  func testFullMessageWithAttachmentsHasMultipartBody() {
    let email = Email(from: "test1@johnbrownlee.com", recipients: ["test2@johnbrownlee.com","test3@johnbrownlee.com"], subject: "Yo", body: "Yo dawg",
      attachments: [Email.Attachment(type: "application/pdf", filename: "contract.pdf", data: NSData(bytes: [1,2,3,4,5,6,7,8,9,10]))]
    )
    let date = Timestamp.now().format(TimeFormat.Rfc2822)
    let messageData = email.fullMessage
    let message = NSString(data: messageData, encoding: NSASCIIStringEncoding) as? String ?? ""
    let strippedMessage = message.stringByReplacingOccurrencesOfString("\r", withString: "")
    let regex = try! NSRegularExpression(pattern: "boundary=\"([A-Z0-9a-z]*)\"", options: [.DotMatchesLineSeparators])
    let matches = regex.matchesInString(strippedMessage, options: [], range: NSMakeRange(0, strippedMessage.characters.count))
    if matches.count == 0 {
      assert(false, message: "Did not contain boundary")
      return
    }
    if matches[0].numberOfRanges < 2 {
      assert(false, message: "Did not have enough ranges")
      return
    }
    let range = matches[0].rangeAtIndex(1)
    let boundary = strippedMessage.substringWithRange(strippedMessage.startIndex.advancedBy(range.location)..<strippedMessage.startIndex.advancedBy(range.location + range.length))
    assert(message, equals:
      "From: test1@johnbrownlee.com\r\n" +
        "To: test2@johnbrownlee.com,test3@johnbrownlee.com\r\n" +
        "Date: \(date)\r\n" +
        "Subject: Yo\r\n" +
        "Content-Type: multipart/mixed; boundary=\"\(boundary)\"\r\n\r\n" +
        "--\(boundary)\r\n" +
        "Content-Type: text/html; charset=UTF-8\r\n" +
        "Content-Transfer-Encoding: quoted-printable\r\n" +
        "\r\n" +
        email.body + "\r\n" +
        "--\(boundary)\r\n" +
        "Content-Type: application/pdf\r\n" +
        "Content-Transfer-Encoding: base64\r\n" +
        "Content-Disposition: attachment; filename=\"contract.pdf\"\r\n" +
        "\r\n" +
        "AQIDBAUGBwgJCg==\r\n" +
        "--\(boundary)--"
    )
  }
  
  func testFullMessageSupportsLongAttachmentNames() {
    let email = Email(from: "test1@johnbrownlee.com", recipients: ["test2@johnbrownlee.com","test3@johnbrownlee.com"], subject: "Yo", body: "Yo dawg",
      attachments: [Email.Attachment(type: "application/pdf", filename: "My Long Filename 1234 Version 1.pdf", data: NSData(bytes: [1,2,3,4,5,6,7,8,9,10]))]
    )
    let messageData = email.fullMessage
    let message = NSString(data: messageData, encoding: NSASCIIStringEncoding) as? String ?? ""
    assert(message, contains: "Content-Disposition: attachment; filename=\"My Long Filename 1234 Version 1.pdf\"")
  }
  
  func testEncodeEncodesNonAsciiCharacters() {
    let content = Email.encode("Olé All")
    assert(content, equals: "Ol=C3=A9 All".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeEncodesEqualsSign() {
    let content = Email.encode("1+2=3")
    assert(content, equals: "1+2=3D3".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeEncodesLineBreakWithCarriageReturnAndLineFeed() {
    let content = Email.encode("Lorem ipsum\ndolor sit amet")
    assert(content, equals: "Lorem ipsum\r\ndolor sit amet".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeEncodesCarriageReturnAndLineFeedWithCarriageReturnAndLineFeed() {
    let content = Email.encode("Lorem ipsum\r\ndolor sit amet")
    assert(content, equals: "Lorem ipsum\r\ndolor sit amet".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeEscapesSpaceBeforeLineBreak() {
    let content = Email.encode("Lorem ipsum  \ndolor sit amet")
    assert(content, equals: "Lorem ipsum =20\r\ndolor sit amet".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeWrapsAt76Characters() {
    let content = Email.encode("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    assert(content, equals: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tem=\r\npor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, q=\r\nuis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo cons=\r\nequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillu=\r\nm dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non pr=\r\noident, sunt in culpa qui officia deserunt mollit anim id est laborum.".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeWrapsEarlyToAvoidBreakingEscape() {
    let content = Email.encode("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod témpor incididunt ut labore et dolore magna aliqua. Ut enim ad minim véniam, quis nostrud exercitation ullamco laboris nisi ut aliquip éx ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    assert(content, equals: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod t=\r\n=C3=A9mpor incididunt ut labore et dolore magna aliqua. Ut enim ad minim v=\r\n=C3=A9niam, quis nostrud exercitation ullamco laboris nisi ut aliquip =C3=\r\n=A9x ea commodo consequat. Duis aute irure dolor in reprehenderit in volupt=\r\nate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occae=\r\ncat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim =\r\nid est laborum.".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeWithLineBreakerUsesThatToSeparateLines() {
    let content = Email.encode("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", lineBreaker: [61,61,61,13,10,61,61,61])
    assert(content, equals: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod t===\r\n===empor incididunt ut labore et dolore magna aliqua. Ut enim ad minim ve===\r\n===niam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea ===\r\n===commodo consequat. Duis aute irure dolor in reprehenderit in voluptate===\r\n=== velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occ===\r\n===aecat cupidatat non proident, sunt in culpa qui officia deserunt molli===\r\n===t anim id est laborum.".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeWithLineBreakerWithoutProperCharactersMakesOneGiantLine() {
    
    let content = Email.encode("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", lineBreaker: [61])
    assert(content, equals: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tem=por incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, =quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo co=nsequat. Duis aute irure dolor in reprehenderit in voluptate velit esse ci=llum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat no=n proident, sunt in culpa qui officia deserunt mollit anim id est laborum.".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeWithInitialLineLengthCutsOffFirstLineEarly() {
    let content = Email.encode("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", initialLineLength: 5)
    assert(content, equals: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmo=\r\nd tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veni=\r\nam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo=\r\n consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse =\r\ncillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat n=\r\non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testEncodeWithSpecialEscapesEncodesThoseCharactersToo() {
    let content = Email.encode("Lorem ipsum dolor\n sit amét", specialEscapes: [32, 10, 13])
    assert(content, equals: "Lorem=20ipsum=20dolor=0A=20sit=20am=C3=A9t".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testDeliverDeliversEmailWithSharedAgent() {
    SHARED_EMAIL_AGENT = MemoryEmailAgent()
    MemoryEmailAgent.deliveries = []
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    email.deliver()
    assert(MemoryEmailAgent.deliveries, equals: [email])
  }
  
  func testDeliverWithNoCallbackLogsError() {
    class TestEmailAgent: EmailAgent {
      convenience init() { self.init([:]) }
      required init(_ config: [String:String]) {}
      func deliver(email: Email, callback: Email.ResultHandler) {
        callback(success: false, code: 123, message: "bad")
      }
    }
    
    SHARED_EMAIL_AGENT = TestEmailAgent()
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    email.deliver()
  }
  
  func testDeliverGivesCallbackToEmailAgent() {
    class TestEmailAgent: EmailAgent {
      convenience init() { self.init([:]) }
      required init(_ config: [String:String]) {}
      func deliver(email: Email, callback: Email.ResultHandler) {
        callback(success: false, code: 123, message: "bad")
      }
    }
    
    SHARED_EMAIL_AGENT = TestEmailAgent()
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    let expectation = expectationWithDescription("callback called")
    email.deliver() {
      success, code, message in
      expectation.fulfill()
      XCTAssertFalse(success)
      XCTAssertEqual(code, 123)
      XCTAssertEqual(message, "bad")
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testEmailsWithSameInformationAreEqual() {
    let email1 = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    let email2 = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    assert(email1, equals: email2)
  }
  func testEmailsWithDifferentSendersAreNotEqual() {
    let email1 = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    let email2 = Email(from: "test3@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    assert(email1, doesNotEqual: email2)
  }
  
  func testEmailsWithDifferentRecipientsAreNotEqual() {
    let email1 = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    let email2 = Email(from: "test1@johnbrownlee.com", to: "test3@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    assert(email1, doesNotEqual: email2)
  }
  
  func testEmailsWithDifferentSubjectsAreNotEqual() {
    let email1 = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    let email2 = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yooo", body: "Yo dawg")
    assert(email1, doesNotEqual: email2)
  }
  
  func testEmailsWithDifferentContentsAreNotEqual() {
    let email1 = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    let email2 = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo buddy")
    assert(email1, doesNotEqual: email2)
  }
  
  func testEmailAttachmentsWithSameInformationAreEqual() {
    let attachment1 = Email.Attachment(type: "image/jpeg", filename: "profile.jpg", data: NSData(bytes: [1,2,3,4]))
    let attachment2 = Email.Attachment(type: "image/jpeg", filename: "profile.jpg", data: NSData(bytes: [1,2,3,4]))
    assert(attachment1, equals: attachment2)
  }
  
  func testEmailAttachmentsWithDifferentTypesAreNotEqual() {
    let attachment1 = Email.Attachment(type: "image/jpeg", filename: "profile.jpg", data: NSData(bytes: [1,2,3,4]))
    let attachment2 = Email.Attachment(type: "image/gif", filename: "profile.jpg", data: NSData(bytes: [1,2,3,4]))
    assert(attachment1, doesNotEqual: attachment2)
  }
  
  func testEmailAttachmentsWithDifferentFilenamesAreNotEqual() {
    let attachment1 = Email.Attachment(type: "image/jpeg", filename: "profile.jpg", data: NSData(bytes: [1,2,3,4]))
    let attachment2 = Email.Attachment(type: "image/jpeg", filename: "profile2.jpg", data: NSData(bytes: [1,2,3,4]))
    assert(attachment1, doesNotEqual: attachment2)
  }
  
  func testEmailAttachmentsWithDifferentDataAreNotEqual() {
    let attachment1 = Email.Attachment(type: "image/jpeg", filename: "profile.jpg", data: NSData(bytes: [1,2,3,4]))
    let attachment2 = Email.Attachment(type: "image/jpeg", filename: "profile.jpg", data: NSData(bytes: [1,2,3,5]))
    assert(attachment1, doesNotEqual: attachment2)
  }
}