@testable import Tailor
import TailorTesting

class EmailTests: TailorTestCase {
  func testInitializeSetsFields() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    assert(email.from, equals: "test1@johnbrownlee.com")
    assert(email.to, equals: "test2@johnbrownlee.com")
    assert(email.subject, equals: "Yo")
    assert(email.body, equals: "Yo dawg")
  }
  
  func testFullMessageContainsHeadersAndBody() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    let date = Timestamp.now().format(TimeFormat.Rfc2822)
    let message = email.fullMessage
    assert(message, contains: "From: test1@johnbrownlee.com\r\n")
    assert(message, contains: "To: test2@johnbrownlee.com\r\n")
    assert(message, contains: "Date: \(date)\r\n")
    assert(message, contains: "Content-Type: text/html; charset=UTF-8\r\n")
    assert(message, contains: "Content-Transfer-Encoding: quoted-printable\r\n")
    assert(message, contains: "Subject: Yo\r\n")
    assert(message, contains: email.body)
  }
  
  func testFullMessageEncodesNonAsciiCharacters() {
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Olé All")
    let message = email.fullMessage
    assert(message, contains: "Ol=C3=A9 All")
  }
  
  func testEncodeEncodesNonAsciiCharacters() {
    let content = Email.encode("Olé All")
    assert(content, equals: "Ol=C3=A9 All")
  }
  
  func testEncodeEncodesEqualsSign() {
    let content = Email.encode("1+2=3")
    assert(content, equals: "1+2=3D3")
  }
  
  func testEncodeEncodesLineBreakWithCarriageReturnAndLineFeed() {
    let content = Email.encode("Lorem ipsum\ndolor sit amet")
    assert(content, equals: "Lorem ipsum\r\ndolor sit amet")
  }
  
  func testEncodeEncodesCarriageReturnAndLineFeedWithCarriageReturnAndLineFeed() {
    let content = Email.encode("Lorem ipsum\r\ndolor sit amet")
    assert(content, equals: "Lorem ipsum\r\ndolor sit amet")
  }
  
  func testEncodeEscapesSpaceBeforeLineBreak() {
    let content = Email.encode("Lorem ipsum  \ndolor sit amet")
    assert(content, equals: "Lorem ipsum =20\r\ndolor sit amet")
  }
  
  func testEncodeWrapsAt76Characters() {
    let content = Email.encode("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    assert(content, equals: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tem=\r\npor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, q=\r\nuis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo cons=\r\nequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillu=\r\nm dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non pr=\r\noident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
  }
  
  func testDeliverDeliversEmailWithSharedAgent() {
    SHARED_EMAIL_AGENT = MemoryEmailAgent([:])
    MemoryEmailAgent.deliveries = []
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    email.deliver()
    assert(MemoryEmailAgent.deliveries, equals: [email])
  }
  
  func testDeliverIgnoresErrors() {
    final class FailingEmailAgent: EmailAgent {
      init(_ config: [String:String]) {
        
      }
      enum Errors: ErrorType {
        case CannotDeliver
      }
      func deliver(email: Email) throws {
        throw Errors.CannotDeliver
      }
    }
    SHARED_EMAIL_AGENT = FailingEmailAgent([:])
    let email = Email(from: "test1@johnbrownlee.com", to: "test2@johnbrownlee.com", subject: "Yo", body: "Yo dawg")
    email.deliver()
    assert(true, message: "Did not die")
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
}